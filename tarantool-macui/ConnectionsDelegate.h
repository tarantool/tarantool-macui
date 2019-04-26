//
//  ConnectionsDelegate.h
//  tarantoolui
//
//  Created by Michael Filonenko on 11/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#include <tarantool/tarantool.h>
#include <tarantool/tnt_net.h>
#include <tarantool/tnt_opt.h>

enum {
    ERROR,
    CONNECTING,
    CONNECTED,
};

@interface NSTntStream : NSObject

- (id) initWith:(struct tnt_stream*)tnt;
- (void)dealloc;

- (struct tnt_stream*) tnt;

@end

@interface ConnectionsDelegate : NSObject <NSTableViewDelegate>

@property (nonatomic,weak) IBOutlet NSArrayController *connectionsController;
@property (nonatomic,weak) IBOutlet NSUserDefaultsController *defaultsController;

-(IBAction)addConnectionFired:(NSButton *)sender;
-(IBAction)removeConnectionFired:(NSButton *)sender;

-(void)awakeFromNib;

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                       change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                      context:(void *)context;

@end

