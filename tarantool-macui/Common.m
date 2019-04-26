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
    if ([self objCType][0] == @encode(bool)[0]) {
        return [NSNumber numberWithBool:[self boolValue]];
    } else if ([self objCType][0] == @encode(char)[0]) {
        return [NSNumber numberWithChar:[self charValue]];
    } else if ([self objCType][0] == @encode(unsigned char)[0]) {
        return [NSNumber numberWithUnsignedChar:[self unsignedCharValue]];
    } else if ([self objCType][0] == @encode(short)[0]) {
        return [NSNumber numberWithShort:[self shortValue]];
    } else if ([self objCType][0] == @encode(unsigned short)[0]) {
        return [NSNumber numberWithUnsignedShort:[self unsignedShortValue]];
    } else if ([self objCType][0] == @encode(int)[0]) {
        return [NSNumber numberWithInt:[self intValue]];
    } else if ([self objCType][0] == @encode(unsigned int)[0]) {
        return [NSNumber numberWithUnsignedInt:[self unsignedIntValue]];
    } else if ([self objCType][0] == @encode(long)[0]) {
        return [NSNumber numberWithLong:[self longValue]];
    } else if ([self objCType][0] == @encode(unsigned long)[0]) {
        return [NSNumber numberWithUnsignedLong:[self unsignedLongValue]];
    } else if ([self objCType][0] == @encode(long long)[0]) {
        return [NSNumber numberWithLongLong:[self longLongValue]];
    } else if ([self objCType][0] == @encode(unsigned long long)[0]) {
        return [NSNumber numberWithUnsignedLongLong:[self unsignedLongLongValue]];
    } else if ([self objCType][0] == @encode(float)[0]) {
        return [NSNumber numberWithFloat:[self floatValue]];
    } else if ([self objCType][0] == @encode(double)[0]) {
        return [NSNumber numberWithDouble:[self doubleValue]];
    } else {
        assert(false);
    }
    
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
