//
//  AddSpaceDelegate.m
//  tarantoolui
//
//  Created by Michael Filonenko on 17/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#import "CreateSpaceDelegate.h"

#import "ConnectionsDelegate.h"

#import "Common.h"
#import "CreateSpace.h"
#import "AlterSpace.h"

@implementation CreateSpaceDelegate

@synthesize selectedConnection;
@synthesize createSpaceObject;

@synthesize spacesController;

@synthesize isnew;
@synthesize origin;

@synthesize formatController;
@synthesize indexController;

- (void) alert:(NSString*)message window:(NSWindow*)window {
    NSAlert *msg = [NSAlert new];
    [msg addButtonWithTitle:@"Ok"];      // 1st button
    [msg setMessageText:@"Error"];
    [msg setInformativeText:message];
    [msg beginSheetModalForWindow:window completionHandler:nil];
}


- (IBAction)stopModal:(nonnull id)sender {
    NSError *err;
    if (![createSpaceObject commitEditingAndReturnError:&err]) {
        [self alert:[err localizedDescription] window:[sender window]];
        return;
    }
    
    dispatch_queue_t serialTntQueue = [selectedConnection objectForKey:@"tnt_queue"];
    struct tnt_stream *tnt = [(NSTntStream*)[selectedConnection objectForKey:@"tnt_stream"] tnt];
    id content = self.createSpaceObject.content;
    id origin = self.origin;
    BOOL isnew = self.isnew;
    dispatch_async(serialTntQueue, ^{
        NSMutableArray *result;
        if (isnew) {
            result = createSpace(tnt, content);
        } else {
            result = alterSpace(tnt, [origin objectForKey:@"name"], content);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[result objectAtIndex:0] isKindOfClass:NSNull.class]) {
                [self alert:[result objectAtIndex:1] window:[sender window]];
                return;
            }
            
            if (isnew) {
                [self.spacesController addObject:[result objectAtIndex:0]];
            } else {
                NSMutableDictionary *altered = [result objectAtIndex:0];
                NSEnumerator *enumerator = [altered keyEnumerator];
                id key;
                while ((key = [enumerator nextObject]))
                    [self.origin setObject:[altered objectForKey:key] forKey:key];
            }
            
            [NSApp endSheet:[sender window] returnCode:NSModalResponseOK];
            [[sender window] orderOut:[[sender window] parentWindow]];
        });
    });
}

-(IBAction)abortModal:(id)sender {
    [NSApp endSheet:[sender window] returnCode:NSModalResponseAbort];
    [[sender window] orderOut:[[sender window] parentWindow]];
}

- (void)controlTextDidEndEditing:(NSNotification *)notification {
    if ([[notification object] isKindOfClass:NSSearchField.class]) {
        NSString *str = [(NSTextField*)[notification object] objectValue];
        @try {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:str];
            if ([[[notification object] identifier] isEqualToString:@"format-search"])
                formatController.filterPredicate = predicate;
            else if ([[[notification object] identifier] isEqualToString:@"index-search"])
                indexController.filterPredicate = predicate;
        } @catch(...) {
            
        }
    }
}

@end
