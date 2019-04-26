//
//  SpacesDelegate.h
//  tarantoolui
//
//  Created by Michael Filonenko on 08/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "../box.schema/CreateSpaceDelegate.h"
#import "../box.schema/DropSpaceDelegate.h"

@interface SpacesDelegate : NSObject<NSTextFieldDelegate>

@property (nonatomic, weak) IBOutlet NSPanel *searchPanel;

@property (nonatomic, weak) IBOutlet NSArrayController *spacesController;
@property (nonatomic, weak) IBOutlet NSTableView *spacesView;

@property (nonatomic, weak) IBOutlet NSPredicateEditor *editor;

@property (nonatomic, weak) IBOutlet NSArrayController *connectionsController;

@property (nonatomic, weak) IBOutlet NSPanel *settingsPanel;

@property (nonatomic, weak) IBOutlet NSWindow *createSpaceWindow;
@property (nonatomic, strong) NSArray *createSpaceGuard;
@property (nonatomic, weak) IBOutlet CreateSpaceDelegate *createSpaceDelegate;

@property (nonatomic, weak) IBOutlet NSWindow *dropSpaceWindow;
@property (nonatomic, strong) NSArray *dropSpaceGuard;
@property (nonatomic, weak) IBOutlet DropSpaceDelegate *dropSpaceDelegate;

@property (nonatomic, weak) IBOutlet NSTextField *name;

- (void)awakeFromNib;

- (IBAction)openFilterEditor:(id)sender;

- (IBAction)add:(id)sender;
- (IBAction)remove:(id)sender;

- (void)controlTextDidEndEditing:(NSNotification *)obj;

- (IBAction)refresh:(id)sender;

- (IBAction)settingsAction:(id)sender;
- (IBAction)settingsEndAction:(id)sender;

@end

