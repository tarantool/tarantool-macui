//
//  GetSpaces.m
//  tarantoolui
//
//  Created by Michael Filonenko on 08/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//
#import "GetSpaces.h"

#import <Foundation/Foundation.h>

#import "MessagePack2NS.h"
#import "NS2MessagePack.h"

#import "Common.h"

NSMutableArray* eval(struct tnt_stream *tnt, NSString* command, NSArray* args) {
    if (tnt == NULL) {
        return [NSMutableArray arrayWithArray:@[[NSNull null], @"No connection"]];
    }
    
    if (args == nil) {
        args = @[];
    }
    
    struct tnt_stream* evalargs = tnt_object(NULL);
    ns2MessagePack(args, evalargs);
    
    ssize_t towrite = tnt_eval(tnt, [command UTF8String], strlen([command UTF8String]), evalargs);
    tnt_stream_free(evalargs);
    
    if (towrite <= 0) {
        NSLog(@"%s", tnt_strerror(tnt));
        return [NSMutableArray arrayWithArray:@[[NSNull null], @(tnt_strerror(tnt))]];
    }
    
    ssize_t rc = tnt_flush(tnt);
    if (rc <= 0) {
        NSLog(@"%s", tnt_strerror(tnt));
        return [NSMutableArray arrayWithArray:@[[NSNull null], @(tnt_strerror(tnt))]];
    }
    
    struct tnt_reply* reply = tnt_reply_init(NULL);
    if (reply == NULL) {
        NSLog(@"Non memory for tnt reply");
        
        return [NSMutableArray arrayWithArray:@[[NSNull null], @"No memory"]];
    }
    
    rc = tnt->read_reply(tnt, reply);
    if (rc < 0) {
        NSLog(@"%s", tnt_strerror(tnt));
        return [NSMutableArray arrayWithArray:@[[NSNull null], @(tnt_strerror(tnt))]];
    }
    if (reply->code != 0) {
        NSString *errmsg = [[NSString alloc] initWithBytes:reply->error
                                                    length:(reply->error_end - reply->error)
                                                  encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@", errmsg);
        return [NSMutableArray arrayWithArray:@[[NSNull null], errmsg]];
    }
    
    NSMutableArray *result = messagePack2NS(reply->data);
    tnt_reply_free(reply);
    return result;
}

NSMutableArray* getSpaces(struct tnt_stream *tnt, BOOL showSystem) {
    static NSString *getSpacesCommand;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *main = [NSBundle mainBundle];
        NSString *resourcePath = [main pathForResource:@"getspaces" ofType:@"lua"];
        NSError *error;
        getSpacesCommand = [NSString
                            stringWithContentsOfFile:resourcePath
                            encoding:NSUTF8StringEncoding
                            error:&error];
        if (getSpacesCommand == nil) {
            NSLog(@"%@", error);
            exit(1);
        }
    });
    
    return eval(tnt, getSpacesCommand, @[[NSNumber numberWithBool:showSystem]]);
}



