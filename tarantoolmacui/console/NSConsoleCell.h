//
//  NSConsoleCell.h
//  tarantoolui
//
//  Created by Michael Filonenko on 14/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSConsoleCell : NSTextFieldCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView;

@end

NS_ASSUME_NONNULL_END
