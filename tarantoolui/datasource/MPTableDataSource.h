//
//  MPTableDataSource.h
//  tarantoolui
//
//  Created by Michael Filonenko on 06/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MPTableDataSource : NSObject <NSTableViewDataSource>

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView;
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;

- (void)setMsgPackData:(char*) reply;

@end
