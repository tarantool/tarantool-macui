//
//  DataDelegate.h
//  tarantoolui
//
//  Created by Michael Filonenko on 15/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DataDelegate : NSObject <NSTextFieldDelegate, NSTableViewDataSource>

@property (weak) IBOutlet NSArrayController *connectionsController;

@property (weak) IBOutlet NSArrayController *spacesController;
@property (weak) IBOutlet NSTableView *spacesView;

@property (weak) IBOutlet NSTableView *dataView;

@property (weak) IBOutlet NSSearchField *searchField;
@property (weak) IBOutlet NSPopUpButton *rowcountField;

- (IBAction)next:(id)sender;
- (IBAction)prev:(id)sender;

- (IBAction)rowcount:(id)sender;

- (void)awakeFromNib;

- (void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                      context:(void *)context;

@end
