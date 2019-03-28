//
//  GetData.m
//  tarantoolui
//
//  Created by Michael Filonenko on 08/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//
#import "GetData.h"

#import <Foundation/Foundation.h>

#import "MessagePack2NS.h"

#import "Common.h"

#import "GetSpaces.h"

NSMutableArray* getData(struct tnt_stream *tnt, NSString* space,
                        NSInteger limit, id from, id search) {
    assert(space!=nil);
    assert(from!=nil);
    
    if (search == nil) {
        search = [NSNull null];
    }
    
    static NSString *getDataCommand;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *main = [NSBundle mainBundle];
        NSString *resourcePath = [main pathForResource:@"getdata" ofType:@"lua"];
        NSError *error;
        getDataCommand = [NSString stringWithContentsOfFile:resourcePath
                                                       encoding:NSUTF8StringEncoding
                                                          error:&error];
        if (getDataCommand == nil) {
            NSLog(@"%@", error);
            exit(1);
        }
    });
    return eval(tnt, getDataCommand, @[space, [NSNumber numberWithInteger:limit],
                                       from, search]);
}
