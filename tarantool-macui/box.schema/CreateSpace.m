//
//  AddSpace.m
//  tarantoolui
//
//  Created by Michael Filonenko on 17/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#import "CreateSpace.h"
#import "GetSpaces.h"

#import <Foundation/Foundation.h>

#import "MessagePack2NS.h"
#import "NS2MessagePack.h"

#import "Common.h"

NSMutableArray* createSpace(struct tnt_stream *tnt, NSDictionary* space) {
    static NSString *createSpaceCommand;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *main = [NSBundle mainBundle];
        NSString *resourcePath = [main pathForResource:@"createspace" ofType:@"lua"];
        NSError *error;
        createSpaceCommand = [NSString stringWithContentsOfFile:resourcePath
                                                      encoding:NSUTF8StringEncoding
                                                         error:&error];
        if (createSpaceCommand == nil) {
            NSLog(@"%@", error);
            exit(1);
        }
    });
    
    return eval(tnt, createSpaceCommand, @[space]);
}
