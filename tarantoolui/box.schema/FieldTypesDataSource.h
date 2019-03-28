//
//  FieldTypesDataSource.h
//  tarantoolui
//
//  Created by Michael Filonenko on 16/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface FieldTypesDataSource : NSObject<NSComboBoxDataSource, NSComboBoxCellDataSource>

+ (FieldTypesDataSource*)fieldTypesDataSourceShared;

- (NSString *)comboBox:(NSComboBox *)comboBox completedString:(NSString *)string;
- (NSUInteger)comboBox:(NSComboBox *)comboBox indexOfItemWithStringValue:(NSString *)string;
- (id)comboBox:(NSComboBox *)comboBox objectValueForItemAtIndex:(NSInteger)index;

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)comboBox;

- (NSString *)comboBoxCell:(NSComboBoxCell *)comboBoxCell
           completedString:(NSString *)uncompletedString;

- (NSUInteger)comboBoxCell:(NSComboBoxCell *)comboBoxCell indexOfItemWithStringValue:(NSString *)string;

- (id)comboBoxCell:(NSComboBoxCell *)comboBoxCell objectValueForItemAtIndex:(NSInteger)index;

- (NSInteger)numberOfItemsInComboBoxCell:(NSComboBoxCell *)comboBoxCell;
@end

NS_ASSUME_NONNULL_END
