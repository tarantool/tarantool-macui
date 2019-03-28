//
//  DropSpace.m
//  tarantoolui
//
//  Created by Michael Filonenko on 18/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#import "DropSpace.h"

#import "GetSpaces.h"

#import "MessagePack2NS.h"
#import "NS2MessagePack.h"

#import "Common.h"


NSMutableArray* dropSpace(struct tnt_stream *tnt, NSString* space) {
    static NSString *dropSpaceCommand;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *main = [NSBundle mainBundle];
        NSString *resourcePath = [main pathForResource:@"dropspace" ofType:@"lua"];
        NSError *error;
        dropSpaceCommand = [NSString stringWithContentsOfFile:resourcePath
                                                       encoding:NSUTF8StringEncoding
                                                          error:&error];
        if (dropSpaceCommand == nil) {
            NSLog(@"%@", error);
            exit(1);
        }
    });
    return eval(tnt, dropSpaceCommand, @[space]);
}
