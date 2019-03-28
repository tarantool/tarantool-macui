//
//  Common.m
//  tarantoolui
//
//  Created by Michael Filonenko on 15/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Common.h"


#pragma mark - NSDictionary

@implementation NSDictionary (ATMutableDeepCopy)

- (id)mutableDeepCopy {
    return [NSMutableDictionary dictionaryWithObjects:self.allValues.mutableDeepCopy
                                              forKeys:self.allKeys.mutableDeepCopy];
}

@end

#pragma mark - NSArray

@implementation NSArray (ATMutableDeepCopy)

- (id)mutableDeepCopy {
    NSMutableArray *const mutableDeepCopy = [NSMutableArray new];
    for (id object in self) {
        [mutableDeepCopy addObject:[object mutableDeepCopy]];
    }
    
    return mutableDeepCopy;
}

@end

#pragma mark - NSNull

@implementation NSNull (ATMutableDeepCopy)

- (id)mutableDeepCopy {
    return self;
}

@end

#pragma mark - NSNumber

@implementation NSNumber (ATMutableDeepCopy)

- (id) mutableDeepCopy {
    if ([self objCType][0] == 'c') {
        return [NSNumber numberWithChar:[self charValue]];
    } else if ([self objCType][0] == 'C') {
        return [NSNumber numberWithChar:[self charValue]];
    } else if ([self objCType][0] == 'i') {
        return [NSNumber numberWithChar:[self integerValue]];
    } else if ([self objCType][0] == 'I') {
        return [NSNumber numberWithChar:[self integerValue]];
    } else if ([self objCType][0] == 'l') {
        return [NSNumber numberWithChar:[self longLongValue]];
    } else if ([self objCType][0] == 'L') {
        return [NSNumber numberWithChar:[self longLongValue]];
    } else if ([self objCType][0] == 'q') {
        return [NSNumber numberWithChar:[self longLongValue]];
    } else if ([self objCType][0] == 'Q') {
        return [NSNumber numberWithChar:[self longLongValue]];
    } else if ([self objCType][0] == 'd') {
        return [NSNumber numberWithChar:[self doubleValue]];
    } else if ([self objCType][0] == 'f') {
        return [NSNumber numberWithChar:[self floatValue]];
    } else {
        assert(false);
    }
}

@end

#pragma mark - NSString

@implementation NSString (ATMutableDeepCopy)
- (id) mutableDeepCopy {
    return [NSMutableString stringWithString:self];
}
@end
