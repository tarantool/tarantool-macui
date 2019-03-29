//
//  NS2Lua.m
//  tarantoolui
//
//  Created by Michael Filonenko on 24/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#import "NS2Lua.h"

NSString* ns2Lua(id obj) {
    NSMutableString *result = [NSMutableString string];
    
    if (obj == nil || [obj isKindOfClass:NSNull.class]) {
        return [NSString stringWithUTF8String:"nil"];
    } else if ([obj isKindOfClass:NSString.class]) {
        return [NSString stringWithFormat:@"\"%@\"", obj];
    } else if ([obj isKindOfClass:NSNumber.class]) {
        return [NSString stringWithFormat:@"%@", obj];
    } else if ([obj isKindOfClass:NSDictionary.class]) {
        
        [result appendString:@"{"];
        NSEnumerator *enumerator = [obj keyEnumerator];
        id key;
        while ((key = [enumerator nextObject])) {
            [result appendString:key];
            [result appendString:@"="];
            [result appendString:ns2Lua([obj objectForKey:key])];
            [result appendString:@","];
        }
        [result appendString:@"}"];
        
    } else if ([obj isKindOfClass:NSArray.class]) {
        [result appendString:@"{"];
        for (uint32_t i = 0; i < [obj count]; ++i) {
            [result appendString:ns2Lua([obj objectAtIndex:i])];
            [result appendString:@","];
        }
        [result appendString:@"}"];
    }
    return result;
}
