//
//  DropSpaceDelegate.m
//  tarantoolui
//
//  Created by Michael Filonenko on 18/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#import "DropSpaceDelegate.h"

#import "Common.h"

#import "ConnectionsDelegate.h"

@implementation DropSpaceDelegate

@synthesize selectedConnection;
@synthesize objectsController;
@synthesize textField;

- (void)resetObjects {
    textField.stringValue = @"";
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self resetObjects];
}

- (void) alert:(NSString*)message window:(NSWindow*)window {
    NSAlert *msg = [NSAlert new];
    [msg addButtonWithTitle:@"Ok"];      // 1st button
    [msg setMessageText:@"Error"];
    [msg setInformativeText:message];
    [msg beginSheetModalForWindow:window completionHandler:nil];
}


- (IBAction)stopModal:(nonnull id)sender {
    if ([objectsController.selectedObjects count] < 1)
        return;
    
    id selectedSpace = [objectsController.selectedObjects objectAtIndex:0];
    
    if (![textField.stringValue isEqualToString:[selectedSpace objectForKey:@"name"]]) {
        [self alert:@"Space name mismatch" window:[sender window]];
        return;
    }
    
    NSString *space = [NSString stringWithString:self->textField.stringValue];
    dispatch_queue_t serialTntQueue = [selectedConnection objectForKey:@"tnt_queue"];
    struct tnt_stream *tnt = [(NSTntStream*)[selectedConnection objectForKey:@"tnt_stream"] tnt];
    dispatch_async(serialTntQueue, ^{
        NSMutableArray *result = dropSpace(tnt, space);
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[result objectAtIndex:0] isKindOfClass:NSNull.class]) {
                [self alert:[result objectAtIndex:1] window:[sender window]];
                return;
            }
            
            [self->objectsController removeObject:selectedSpace];
            
            [NSApp endSheet:[sender window] returnCode:NSModalResponseOK];
            [[sender window] orderOut:[[sender window] parentWindow]];
            
            [self resetObjects];
        });
    });
}

-(IBAction)abortModal:(id)sender {
    [NSApp endSheet:[sender window] returnCode:NSModalResponseAbort];
    [[sender window] orderOut:[[sender window] parentWindow]];
    [self resetObjects];
}
@end
