//
//  NS2MessagePack.m
//  tarantoolui
//
//  Created by Michael Filonenko on 15/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#import "NS2MessagePack.h"

#import "Common.h"

void ns2MessagePack(id source, struct tnt_stream* parent) {
    struct tnt_stream *result = parent;
    if (result == NULL) {
        NSLog(@"No memory for tnt stream");
        return;
    }
    
    if (source == nil || [source isKindOfClass:NSNull.class] ) {
        tnt_object_add_nil(result);
    } else if ([source isKindOfClass:NSNumber.class]) {
        if ([source objCType][0] == @encode(bool)[0]) {
            tnt_object_add_bool(result, [source boolValue]);
        } else if ([source objCType][0] == @encode(char)[0]) {
            tnt_object_add_int(result, [source charValue]);
        } else if ([source objCType][0] == @encode(unsigned char)[0]) {
            tnt_object_add_uint(result, [source unsignedCharValue]);
        } else if ([source objCType][0] == @encode(short)[0]) {
            tnt_object_add_int(result, [source shortValue]);
        } else if ([source objCType][0] == @encode(unsigned short)[0]) {
            tnt_object_add_uint(result, [source unsignedShortValue]);
        } else if ([source objCType][0] == @encode(int)[0]) {
            tnt_object_add_int(result, [source intValue]);
        } else if ([source objCType][0] == @encode(unsigned int)[0]) {
            tnt_object_add_uint(result, [source unsignedIntValue]);
        } else if ([source objCType][0] == @encode(long)[0]) {
            tnt_object_add_int(result, [source longValue]);
        } else if ([source objCType][0] == @encode(unsigned long)[0]) {
            tnt_object_add_uint(result, [source unsignedLongValue]);
        } else if ([source objCType][0] == @encode(long long)[0]) {
            tnt_object_add_int(result, [source longLongValue]);
        } else if ([source objCType][0] == @encode(unsigned long long)[0]) {
            tnt_object_add_uint(result, [source unsignedLongLongValue]);
        } else if ([source objCType][0] == @encode(float)[0]) {
            tnt_object_add_float(result, [source floatValue]);
        } else if ([source objCType][0] == @encode(double)[0]) {
            tnt_object_add_double(result, [source doubleValue]);
        } else {
            assert(false);
        }
    } else if ([source isKindOfClass:NSString.class]) {
        tnt_object_add_str(result, [source UTF8String],
                           strlen([source UTF8String]));
    } else if ([source isKindOfClass:NSArray.class]) {
        tnt_object_add_array(result, [source count]);
        for (uint32_t i = 0; i < [source count]; ++i) {
            ns2MessagePack([source objectAtIndex:i], result);
        }
    } else if ([source isKindOfClass:NSDictionary.class]) {
        tnt_object_add_map(result, [(NSDictionary*)source count]);
        NSEnumerator *enumerator = [source keyEnumerator];
        id key;
        
        while ((key = [enumerator nextObject])) {
            ns2MessagePack(key, result);
            ns2MessagePack([source objectForKey:key], result);
        }
    }  else {
        assert(false);
    }
    
    return;
}
