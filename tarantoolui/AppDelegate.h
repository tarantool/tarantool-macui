//
//  AppDelegate.h
//  tarantoolui
//
//  Created by Michael Filonenko on 10/12/2018.
//  Copyright © 2018 tarantool. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ConnectionsDelegate.h"
#import "box.space/SpacesDelegate.h"
#import "ConsoleDelegate.h"
#import "DataDelegate.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate>

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender;

@end

