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

@property (nonatomic,strong) NSDictionary *selectedConnection;

@property (nonatomic,weak) IBOutlet NSObjectController *createSpaceObject;

@property (nonatomic,weak) NSObjectController *spacesController;

@property (atomic) BOOL isnew;
@property (nonatomic,weak) NSMutableDictionary *origin;

@property (nonatomic,weak) IBOutlet NSArrayController *formatController;
@property (nonatomic,weak) IBOutlet NSArrayController *indexController;

- (IBAction)stopModal:(id)sender;
- (IBAction)abortModal:(id)sender;
@end

NS_ASSUME_NONNULL_END
