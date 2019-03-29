//
//  NSConsoleCell.m
//  tarantoolui
//
//  Created by Michael Filonenko on 14/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#import "NSConsoleCell.h"

@implementation NSConsoleCell


- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    NSRect moved = NSMakeRect(cellFrame.origin.x, cellFrame.origin.y,
                              cellFrame.size.width, cellFrame.size.height);
    moved.origin.x += 5;
    [super drawWithFrame:moved inView:controlView];
}

@end
