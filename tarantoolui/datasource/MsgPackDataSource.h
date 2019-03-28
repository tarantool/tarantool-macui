//
//  MsgPackDataSource.h
//  tarantoolui
//
//  Created by Michael Filonenko on 18/12/2018.
//  Copyright © 2018 tarantool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface MsgPackDataSource : NSObject <NSOutlineViewDataSource>

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(nullable id)item;
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(nullable id)item;
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn byItem:(nullable id)item;

- (void)setMsgPackData:(char*) mpdata;
@end
