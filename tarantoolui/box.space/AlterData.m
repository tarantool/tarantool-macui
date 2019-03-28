//
//  AlterData.m
//  tarantoolui
//
//  Created by Michael Filonenko on 26/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#import "AlterData.h"


#import <Foundation/Foundation.h>

#import "MessagePack2NS.h"

#import "Common.h"

#import "GetSpaces.h"

NSMutableArray* alterData(struct tnt_stream *tnt, NSString* space,
                          id origin, id newobj) {
    assert(space!=nil);
    assert(newobj!=nil);
    
    static NSString *alterDataCommand;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *main = [NSBundle mainBundle];
        NSString *resourcePath = [main pathForResource:@"alterdata" ofType:@"lua"];
        NSError *error;
        alterDataCommand = [NSString stringWithContentsOfFile:resourcePath
                                                   encoding:NSUTF8StringEncoding
                                                      error:&error];
        if (alterDataCommand == nil) {
            NSLog(@"%@", error);
            exit(1);
        }
    });
    return eval(tnt, alterDataCommand, @[space, origin, newobj]);
}
