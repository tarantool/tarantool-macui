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

@property (weak) IBOutlet NSPanel *searchPanel;

@property (weak) IBOutlet NSArrayController *spacesController;
@property (weak) IBOutlet NSTableView *spacesView;

@property (weak) IBOutlet NSPredicateEditor *editor;

@property (weak) IBOutlet NSArrayController *connectionsController;

@property (weak) IBOutlet NSPanel *settingsPanel;

@property (weak) IBOutlet NSWindow *createSpaceWindow;
@property (strong) NSArray *createSpaceGuard;
@property (weak) IBOutlet CreateSpaceDelegate *createSpaceDelegate;

@property (weak) IBOutlet NSWindow *dropSpaceWindow;
@property (strong) NSArray *dropSpaceGuard;
@property (weak) IBOutlet DropSpaceDelegate *dropSpaceDelegate;

@property (weak) IBOutlet NSTextField *name;

- (void)awakeFromNib;

- (IBAction)openFilterEditor:(id)sender;

- (IBAction)add:(id)sender;
- (IBAction)remove:(id)sender;

- (void)controlTextDidEndEditing:(NSNotification *)obj;

- (IBAction)refresh:(id)sender;

- (IBAction)settingsAction:(id)sender;
- (IBAction)settingsEndAction:(id)sender;

@end

