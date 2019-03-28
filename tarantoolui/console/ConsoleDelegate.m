//
//  ConsoleDelegate.m
//  tarantoolui
//
//  Created by Michael Filonenko on 13/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#import "ConsoleDelegate.h"

#import "ConnectionsDelegate.h"

#import "Common.h"

#import "GetSpaces.h"

#include <tarantool/tarantool.h>
#include <tarantool/tnt_net.h>
#include <tarantool/tnt_opt.h>

#import "NS2Lua.h"

@implementation ConsoleDelegate

@synthesize connectionsController;

@synthesize consoleController;
@synthesize consoleView;

- (void)awakeFromNib {
    [connectionsController addObserver:self forKeyPath:@"selection" options:NSKeyValueObservingOptionInitial context:NULL];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
}


-(IBAction)console:(id)sender {
    if ([connectionsController.selectedObjects count] < 1)
        return;
    
    NSDictionary *conn = [connectionsController.selectedObjects objectAtIndex:0];
    
    if ([[conn objectForKey:@"state"] intValue] != CONNECTED)
        return;
    
    dispatch_queue_t serialTntQueue = [conn objectForKey:@"tnt_queue"];
    struct tnt_stream *tnt = [(NSTntStream*)[conn objectForKey:@"tnt_stream"] tnt];
    
    NSString *text = [(NSTextField*)sender objectValue];
    
    if (![[text stringByTrimmingCharactersInSet:
           [NSCharacterSet whitespaceAndNewlineCharacterSet]] length])
        return;
    
    consoleController.editable = NO;
    dispatch_async(serialTntQueue, ^{
        NSMutableArray *result = eval(tnt, text, nil);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self->consoleController addObject:[NSMutableDictionary
                                          dictionaryWithObject:text
                                          forKey:@"message"]];
            
            NSString *resultText = ns2Lua(result);
            
            [self->consoleController addObject:[NSMutableDictionary
                                                dictionaryWithObject:resultText
                                                forKey:@"message"]];
            
            [(NSTextField*)sender setObjectValue:@""];
            
            CGFloat width = [[self->consoleView tableColumns] objectAtIndex:0].width;
            NSCell *cell = [[[self->consoleView tableColumns] objectAtIndex:0] dataCell];
            cell.wraps = NO;
            cell.stringValue = text;
            NSRect rect = NSMakeRect(0.0, 0.0, CGFLOAT_MAX, CGFLOAT_MAX);
            
            width = MAX([cell cellSizeForBounds:rect].width, width);
            
            if (width > 2000)
                width = 2000;
            
            [[self->consoleView tableColumns] objectAtIndex:0].width = width;
            
            
            NSUInteger count = [[self->consoleController arrangedObjects] count];
            [self->consoleView scrollRowToVisible:count-1];
            
            self->consoleController.editable = YES;
        });
    });
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    id rowobj = [[consoleController content] objectAtIndex: row];
    if (rowobj == nil)
        return 10;
    
    NSString* content = [rowobj objectForKey:@"message"];
    
    CGFloat height = 10;
    NSCell *cell = [[[tableView tableColumns] objectAtIndex:0] dataCell];
    cell.wraps = NO;
    cell.stringValue = content;
    NSRect rect = NSMakeRect(0.0, 0.0, CGFLOAT_MAX, CGFLOAT_MAX);
    height = MAX([cell cellSizeForBounds:rect].height, height);
    
    if (height > 400)
        height = 400;
    
    return height;
}

@end
