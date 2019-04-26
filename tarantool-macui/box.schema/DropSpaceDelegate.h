//
//  DropSpaceDelegate.h
//  tarantoolui
//
//  Created by Michael Filonenko on 18/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DropSpace.h"

NS_ASSUME_NONNULL_BEGIN

@interface DropSpaceDelegate : NSObject<NSWindowDelegate>

@property (nonatomic,strong) NSDictionary *selectedConnection;

@property (nonatomic,weak) NSObjectController *objectsController;

@property (nonatomic,weak) IBOutlet NSTextField *textField;

- (IBAction)stopModal:(id)sender;
- (IBAction)abortModal:(id)sender;

@end

NS_ASSUME_NONNULL_END
