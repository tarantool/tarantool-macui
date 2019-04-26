//
//  ConnectionsDelegate.m
//  tarantoolui
//
//  Created by Michael Filonenko on 11/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#import "ConnectionsDelegate.h"

#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>

#import "Common.h"
#import "GetSpaces.h"


@implementation NSTntStream {
    struct tnt_stream * tnt;
}

-(id)initWith:(struct tnt_stream *)tnt {
    self = [super init];
    if (self)
        self->tnt = tnt;
    return self;
}

-(void)dealloc {
    if (self->tnt != NULL) {
        tnt_close(self->tnt);
        tnt_stream_free(self->tnt);
        self->tnt = NULL;
    }
}

-(struct tnt_stream*)tnt {
    return self->tnt;
}
@end

@implementation ConnectionsDelegate {
    NSMutableArray *streams;
    NSAlert *msg;
    NSTextField *txt;
}

@synthesize connectionsController;
@synthesize defaultsController;

- (void)addConnectionFired:(NSButton *)sender {
    [msg setAccessoryView:txt];
    
    [msg beginSheetModalForWindow:[sender window]
                    modalDelegate:self
                   didEndSelector:@selector(addConnection:returnCode:contextInfo:)
                      contextInfo:NULL];
}

- (void) addConnection:(NSAlert *)alert
            returnCode:(NSInteger)returnCode
           contextInfo:(void *)contextInfo {
    if (returnCode == NSAlertFirstButtonReturn) {
        NSMutableDictionary *value = [[NSMutableDictionary alloc] init];
        
        [value setObject:txt.stringValue forKey:@"url"];
        dispatch_queue_t serialTntQueue = dispatch_queue_create("io.tarantool.Queue", NULL);
        [value setObject:serialTntQueue forKey:@"tnt_queue"];
        
        [connectionsController addObserver:self
                                forKeyPath:@"content.url"
                                   options:NSKeyValueObservingOptionNew
                                   context:NULL];

        [self->connectionsController addObject:value];
        [self saveState];
    }
}


- (void)removeConnectionFired:(NSButton *)sender {
    [connectionsController remove:sender];
    [self saveState];
}

- (void)observeValueForKeyPath:(nonnull NSString *)keyPath
                      ofObject:(nonnull id)object
                        change:(nonnull NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(nonnull void *)context {
    if (object != connectionsController)
        return;
    
    if ([keyPath isEqualToString:@"selection"]) {
        if ([connectionsController.selectedObjects count] < 1)
            return;
        
        NSMutableDictionary *connection = [connectionsController.selectedObjects objectAtIndex:0];
        [self connectionDidSelected:connection];
        
    } else if ([keyPath isEqualToString:@"content.url"]) {
        [self observeValueForKeyPath:@"selection" ofObject:object change:nil context:NULL];
        
        [self saveState];
    } else if ([keyPath isEqualToString:@"content.alias"]) {
        [self saveState];
    }
}

- (void)connectionDidSelected:(NSMutableDictionary*) obj {
    BOOL connect = NO;
    
    long state = [[obj objectForKey:@"state"] integerValue];
    
    // Check if url changed
    if (state == CONNECTED || state == CONNECTING) {
        assert([obj objectForKey:@"tnt_stream"] != nil);
        
        struct tnt_stream* tnt = [(NSTntStream*)[obj objectForKey:@"tnt_stream"] tnt];
        NSString *url = [obj objectForKey:@"url"];
        assert(url != nil);
        if (TNT_SNET_CAST(tnt)->opt.uristr) {
            size_t len = strlen(TNT_SNET_CAST(tnt)->opt.uristr);
            if (strncmp([url UTF8String], TNT_SNET_CAST(tnt)->opt.uristr, len)) {
                connect = YES;
            }
        }
    }
    
    // Check if disconnected
    if (state == CONNECTED) {
        assert([obj objectForKey:@"tnt_stream"] != nil);
        struct tnt_stream* tnt = [(NSTntStream*)[obj objectForKey:@"tnt_stream"] tnt];
        if (TNT_SNET_CAST(tnt)->fd < 0) {
            connect = YES;
        } else {
            int error_code;
            int error_code_size = sizeof(error_code);
            getsockopt(TNT_SNET_CAST(tnt)->fd, SOL_SOCKET, SO_ERROR,
                       &error_code, &error_code_size);
            if (error_code != 0)
            connect = YES;
        }
    }
    
    if (state == ERROR)
    connect = YES;
    
    if (connect)
    [self establishConnection:obj];
}

- (void)establishConnection:(NSMutableDictionary*) obj {
    [obj setObject:[NSNumber numberWithInteger:ERROR] forKey:@"state"];
                                                                        
    [obj removeObjectForKey:@"tnt_stream"];
    [obj removeObjectForKey:@"schema"];
    [obj removeObjectForKey:@"console"];
    
    NSString *url = [obj valueForKey:@"url"];
    const char* uri = [url UTF8String];
    if (uri == NULL) {
        [obj setObject:@"No url" forKey:@"status"];
        return;
    }
    
    int rc = 0;
    struct tnt_stream *tnt = tnt_net(NULL); // Allocating stream
    rc = tnt_set(tnt, TNT_OPT_URI, strdup(uri)); // Setting URI
    if (rc != 0) {
        NSLog(@"%s", tnt_strerror(tnt));
        [obj setObject:[NSString stringWithFormat:@"%s", tnt_strerror(tnt)]
                forKey:@"status"];
        tnt_stream_free(tnt);
        
        return;
    }
    
    [obj setObject:[[NSTntStream alloc] initWith:tnt] forKey:@"tnt_stream"];
    [obj setObject:[NSNumber numberWithInteger:CONNECTING] forKey:@"state"];
    [obj setObject:@"Connecting..." forKey:@"status"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        int rc = tnt_connect(tnt);
        NSString *error = nil;
        if (rc != 0) {
            error = @(tnt_strerror(tnt));
            NSLog(@"%s", tnt_strerror(tnt));
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (rc != 0) {
                [obj setObject:[NSNumber numberWithInteger:ERROR] forKey:@"state"];
                
                if (error != nil) {
                    [obj setObject:error forKey:@"status"];
                }
                return;
            }
            
            [obj setObject:@"Connected" forKey:@"status"];
            [obj setObject:[NSNumber numberWithInteger:CONNECTED] forKey:@"state"];
        });
    });
}

- (void)saveState {
    NSMutableArray *pureconnections = [[NSMutableArray alloc] init];
    for (uint32_t i = 0; i < [connectionsController.content count]; ++i) {
        NSDictionary *obj = [connectionsController.content objectAtIndex:i];
        [pureconnections addObject:
         @{@"alias": [obj objectForKey:@"alias"]? [obj objectForKey:@"alias"] : @"" ,
           @"url": [obj objectForKey:@"url"]?[obj objectForKey:@"url"]: @"",}];
    }
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    [settings setObject:pureconnections forKey:@"connections"];
}


- (void)restoreState {
    
    connectionsController.selectsInsertedObjects = NO;
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSArray *pureconnections = [NSMutableArray arrayWithArray:[settings arrayForKey:@"connections"]];
    for (uint32_t i = 0; i < [pureconnections count]; ++i) {
        NSDictionary *obj = [pureconnections objectAtIndex:i];
        dispatch_queue_t serialTntQueue = dispatch_queue_create("io.tarantool.Queue", NULL);
        [connectionsController addObject:
         [NSMutableDictionary dictionaryWithDictionary:
            @{@"alias": [obj objectForKey:@"alias"],
                           @"url":[obj objectForKey:@"url"],
                            @"tnt_queue":serialTntQueue,
                           }]];
    }
    connectionsController.selectsInsertedObjects = YES;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    msg = [NSAlert new];
    [msg addButtonWithTitle:@"Ok"];
    [msg addButtonWithTitle:@"Cancel"];
    [msg setMessageText:@"Add connection"];
    [msg setInformativeText:@"Enter url"];
    
    txt = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    txt.stringValue = @"127.0.0.1:3301";
    
    [connectionsController addObserver:self
                            forKeyPath:@"selection"
                               options:NSKeyValueObservingOptionInitial
                               context:NULL];
    
    [connectionsController addObserver:self
                            forKeyPath:@"content.alias"
                               options:NSKeyValueObservingOptionNew
                               context:NULL];

    [self restoreState];
}

@end
