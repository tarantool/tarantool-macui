//
//  DataDelegate.h
//  tarantoolui
//
//  Created by Michael Filonenko on 15/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DataDelegate : NSObject <NSTextFieldDelegate, NSTableViewDataSource>

@property (nonatomic, weak) IBOutlet NSArrayController *connectionsController;

@property (nonatomic, weak) IBOutlet NSArrayController *spacesController;
@property (nonatomic, weak) IBOutlet NSTableView *spacesView;

@property (nonatomic, weak) IBOutlet NSTableView *dataView;

@property (nonatomic, weak) IBOutlet NSSearchField *searchField;
@property (nonatomic, weak) IBOutlet NSPopUpButton *rowcountField;

- (IBAction)next:(id)sender;
- (IBAction)prev:(id)sender;

- (IBAction)rowcount:(id)sender;

- (void)awakeFromNib;

- (void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                      context:(void *)context;

@end
