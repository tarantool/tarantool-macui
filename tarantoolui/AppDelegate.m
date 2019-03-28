//
//  AppDelegate.m
//  tarantoolui
//
//  Created by Michael Filonenko on 10/12/2018.
//  Copyright © 2018 tarantool. All rights reserved.
//

#include <stdlib.h>
#include <stdio.h>

#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>

#include <tarantool/tarantool.h>
#include <tarantool/tnt_net.h>
#include <tarantool/tnt_opt.h>

#import "AppDelegate.h"

#import "GetSpaces.h"
#import "MessagePack2NS.h"


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
}


- (void)applicationWillTerminate:(NSNotification *)notification {    
}

-(BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}


- (void)controlTextDidChange:(NSNotification *)notification {
//    if ([notification object] == formatSearchField) {
//        NSString* filterVal = [(NSTextField*)[notification object] stringValue];
//        if ([filterVal length] == 0) {
//            formatController.filterPredicate = nil;
//            return;
//        }
//
//        @try {
//            NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:filterVal];
//            formatController.filterPredicate = filterPredicate;
//        } @catch (...) {
//            //NSLog(@"Search format is wrong %@", filterVal);
//        }
//    }
}

@end
