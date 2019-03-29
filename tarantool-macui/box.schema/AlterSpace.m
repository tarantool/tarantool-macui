//
//  AlterSpace.m
//  tarantoolui
//
//  Created by Michael Filonenko on 24/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#import "AlterSpace.h"

#import "CreateSpace.h"
#import "GetSpaces.h"

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#import "MessagePack2NS.h"
#import "NS2MessagePack.h"

#import "Common.h"

NSMutableArray* alterSpace(struct tnt_stream *tnt, NSString* name, NSDictionary* space) {
    static NSString *alterSpaceCommand;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *main = [NSBundle mainBundle];
        NSString *resourcePath = [main pathForResource:@"alterspace" ofType:@"lua"];
        NSError *error;
        alterSpaceCommand = [NSString stringWithContentsOfFile:resourcePath
                                                      encoding:NSUTF8StringEncoding
                                                         error:&error];
        if (alterSpaceCommand == nil) {
            NSLog(@"%@", error);
            exit(1);
        }
    });
    
    return eval(tnt, alterSpaceCommand, @[name, space]);
}
