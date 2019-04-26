//
//  ConsoleDelegate.h
//  tarantoolui
//
//  Created by Michael Filonenko on 13/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ConsoleDelegate : NSObject<NSTextViewDelegate>

@property (nonatomic,weak) IBOutlet NSArrayController *connectionsController;

@property (nonatomic,weak) IBOutlet NSArrayController *consoleController;
@property (nonatomic,weak) IBOutlet NSTableView *consoleView;

- (void)awakeFromNib;

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context;

-(IBAction)console:(id)sender;

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row;

@end
