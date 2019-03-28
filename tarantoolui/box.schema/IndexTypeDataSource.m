//
//  IndexTypeDataSource.m
//  tarantoolui
//
//  Created by Michael Filonenko on 24/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#import "IndexTypeDataSource.h"

@implementation IndexTypeDataSource {
    NSArray *types;
}

+ (IndexTypeDataSource*)fieldTypesDataSourceShared {
    static IndexTypeDataSource *empty = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        empty = [[self alloc] init];
    });
    
    return empty;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        types = @[@"TREE",
                  @"HASH",
                  @"BITSET",
                  @"RTREE",
                  ];
    }
    return self;
}

- (NSString *)comboBox:(NSComboBox *)comboBox completedString:(NSString *)string {
    for (uint32_t i = 0; i < [types count]; ++i) {
        if ([[types objectAtIndex:i] hasPrefix:string])
            return [types objectAtIndex:i];
    }
    return nil;
}
- (NSUInteger)comboBox:(NSComboBox *)comboBox indexOfItemWithStringValue:(NSString *)string {
    for (uint32_t i = 0; i < [types count]; ++i) {
        if ([[types objectAtIndex:i] hasPrefix:string])
            return i;
    }
    return -1;
}
- (id)comboBox:(NSComboBox *)comboBox objectValueForItemAtIndex:(NSInteger)index {
    return [types objectAtIndex:index];
}
- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)comboBox {
    return [types count];
}

- (NSInteger)numberOfItemsInComboBoxCell:(nonnull NSComboBoxCell *)comboBoxCell {
    return [types count];
}

- (nonnull NSString *)comboBoxCell:(nonnull NSComboBoxCell *)comboBoxCell completedString:(nonnull NSString *)uncompletedString {
    for (uint32_t i = 0; i < [types count]; ++i) {
        if ([[types objectAtIndex:i] hasPrefix:uncompletedString])
            return [NSString stringWithString:[types objectAtIndex:i]];
    }
    return [NSString stringWithString:[types objectAtIndex:0]];
}
- (NSUInteger)comboBoxCell:(NSComboBoxCell *)comboBoxCell indexOfItemWithStringValue:(NSString *)string {
    for (uint32_t i = 0; i < [types count]; ++i) {
        if ([[types objectAtIndex:i] hasPrefix:string])
            return i;
    }
    return -1;
}
- (id)comboBoxCell:(NSComboBoxCell *)comboBoxCell objectValueForItemAtIndex:(NSInteger)index {
    return [types objectAtIndex:index];
}
@end
