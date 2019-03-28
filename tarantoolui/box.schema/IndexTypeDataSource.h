//
//  IndexTypeDataSource.h
//  tarantoolui
//
//  Created by Michael Filonenko on 24/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface IndexTypeDataSource : NSObject<NSComboBoxDataSource, NSComboBoxCellDataSource>
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
