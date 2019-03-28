//
//  AddSpaceDelegate.h
//  tarantoolui
//
//  Created by Michael Filonenko on 17/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface CreateSpaceDelegate : NSObject

@property (strong) NSDictionary *selectedConnection;

@property (weak) IBOutlet NSObjectController *createSpaceObject;

@property (weak) NSObjectController *spacesController;

@property (atomic) BOOL isnew;
@property (weak) NSMutableDictionary *origin;

@property (weak) IBOutlet NSArrayController *formatController;
@property (weak) IBOutlet NSArrayController *indexController;

- (IBAction)stopModal:(id)sender;
- (IBAction)abortModal:(id)sender;
@end

NS_ASSUME_NONNULL_END
