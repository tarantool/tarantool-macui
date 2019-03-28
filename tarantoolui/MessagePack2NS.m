//
//  MessagePack2NS.m
//  tarantoolui
//
//  Created by Michael Filonenko on 07/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#import "MessagePack2NS.h"

#import <Foundation/Foundation.h>

#include <msgpuck/msgpuck.h>

#import "Common.h"

id messagePack2NS(const char* data) {
    if (data == NULL)
        return nil;
    
    const char* msg = data;
    enum mp_type type = mp_typeof(*msg);
    switch(type) {
        case MP_ARRAY: {
            NSMutableArray *result = [NSMutableArray new];
            uint32_t size = mp_decode_array(&msg);
            for (uint32_t i = 0; i < size; ++i) {
                [result addObject:messagePack2NS(msg)];
                mp_next(&msg);
            }
            return result;
        }
        case MP_MAP: {
            NSMutableDictionary *result = [NSMutableDictionary new];
            uint32_t size = mp_decode_map(&msg);
            for (uint32_t i = 0; i < size; ++i) {
                
                id key = messagePack2NS(msg);
                mp_next(&msg);
                // TODO
                // Make key only string type because of cocoa bindings
                //if (![key isKindOfClass: NSString.class]) {
                //    key = [NSString stringWithFormat:@"%@", key];
                //}
                [result setObject:messagePack2NS(msg) forKey: key];
                mp_next(&msg);
            }
            return result;
        }
        case MP_STR: {
            uint32_t len = 0;
            const char* key = mp_decode_str(&msg, &len);
            NSString *nskey = [[NSString alloc] initWithBytes:key length:len encoding:NSUTF8StringEncoding];
            return nskey;
        }
        case MP_INT: {
            return [[NSNumber alloc] initWithLongLong:mp_decode_int(&msg)];
        }
        case MP_UINT: {
            return [[NSNumber alloc] initWithUnsignedLongLong:mp_decode_uint(&msg)];
        }
        case MP_NIL: {
            mp_decode_nil(&msg);
            return [NSNull null];
        }
        case MP_BOOL: {
            if (mp_decode_bool(&msg)) {
                return [[NSNumber alloc] initWithBool:YES];
            } else {
                return [[NSNumber alloc] initWithBool:NO];
            }
        }
        case MP_BIN: {
            uint32_t len = 0;
            const char* data = mp_decode_bin(&msg, &len);
            return [NSData dataWithBytes:data length:len];
        }
        case MP_EXT: {
            assert(false);
            //mp_next(&msg);
        }
        case MP_FLOAT: {
            float val = mp_decode_float(&msg);
            return [NSNumber numberWithFloat:val];
        }
        case MP_DOUBLE: {
            double val = mp_decode_float(&msg);
            return [NSNumber numberWithDouble:val];
        }
        default:
            assert(false);
            //mp_next(&msg);
    }
    return nil;
}
