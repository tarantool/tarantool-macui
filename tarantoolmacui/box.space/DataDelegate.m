//
//  DataDelegate.m
//  tarantoolui
//
//  Created by Michael Filonenko on 15/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#import "DataDelegate.h"

#import "Common.h"

#import "ConnectionsDelegate.h"

#import "GetData.h"
#import "AlterData.h"

@implementation DataDelegate

@synthesize connectionsController;

@synthesize spacesController;
@synthesize spacesView;

@synthesize dataView;

@synthesize searchField;
@synthesize rowcountField;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [spacesController addObserver:self
                            forKeyPath:@"selection"
                               options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
                               context:NULL];
}

- (void)spaceSelected {
    if ([spacesController.selectedObjects count] < 1)
        return;
    
    NSMutableDictionary *space = [spacesController.selectedObjects objectAtIndex:0];
    
    uint64_t fieldCount = 0;
    if ([[space objectForKey:@"field_count"] unsignedLongLongValue] > fieldCount) {
        fieldCount = [[space objectForKey:@"field_count"] unsignedLongLongValue];
    }
    NSArray *format = [space objectForKey:@"format"];
    if (format != nil) {
        if ([format count] > fieldCount) {
            fieldCount = [format count];
        }
    }
    
    if (fieldCount > 1000) {
        fieldCount = 1000;
    }
    
    if ([[dataView tableColumns] count] < fieldCount) {
        for (uint64_t i = [[dataView tableColumns] count]; i < fieldCount; ++i) {
            NSTableColumn *column = [NSTableColumn new];
            [dataView addTableColumn:column];
        }
    } else {
        uint64_t viewColumns = [[dataView tableColumns] count];
        for (uint64_t i = fieldCount; i < viewColumns; ++i) {
            [dataView removeTableColumn:[[dataView tableColumns] objectAtIndex:fieldCount]];
        }
    }
    
    for (uint64_t i = 0; i < [[dataView tableColumns] count]; ++i) {
        NSTableColumn *column = [[dataView tableColumns] objectAtIndex:i];
        if ([format count] > i) {
            NSDictionary *formatfield = [format objectAtIndex:i];
            [column setTitle:[NSString stringWithFormat:@"%@",
                              [formatfield objectForKey:@"name"]]];
            
            [column setIdentifier:[formatfield objectForKey:@"name"]];
        } else {
            [column setTitle:[NSString stringWithFormat:@"%llu", i+1]];
            
            [column setIdentifier:[NSString stringWithFormat:@"%llu", i+1]];
        }
    }
    
    if ([space objectForKey:@"data"] == nil) {
        [self loadData:rowcountField.selectedTag
                  from:[NSNull null]
         search:searchField.stringValue];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                      context:(void *)context {
    if (![keyPath isEqualToString:@"selection"])
        return;
    
    if (object == spacesController)
        [self spaceSelected];
}

- (void) loadData:(NSInteger)first from:(id)cursor
           search:(NSString*)search {
    if ([connectionsController.selectedObjects count] < 1)
        return;
    
    if ([spacesController.selectedObjects count] < 1)
        return;

    NSDictionary *conn = [connectionsController.selectedObjects objectAtIndex:0];
    
    if ([[conn objectForKey:@"state"] intValue] != CONNECTED)
        return;
    
    dispatch_queue_t serialTntQueue = [conn objectForKey:@"tnt_queue"];
    struct tnt_stream *tnt = [(NSTntStream*)[conn objectForKey:@"tnt_stream"] tnt];

    NSMutableDictionary *space = [spacesController.selectedObjects objectAtIndex:0];
    
    if (cursor == nil)
        cursor = [NSNull null];
    
    dispatch_async(serialTntQueue, ^{
        NSMutableArray *result = getData(tnt, [space objectForKey:@"name"],
                                         first,
                                         cursor,
                                         search);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[result objectAtIndex:0] isKindOfClass:NSNull.class])
                return;
            
            if ([[result objectAtIndex:0] count] < 1)
                return;
            
            [space setObject:[result objectAtIndex:0] forKey:@"data"];
            [self->dataView reloadData];
        });
    });
}

- (IBAction)next:(id)sender {
    if ([spacesController.selectedObjects count] < 1)
        return;
    
    NSDictionary *space = [spacesController.selectedObjects objectAtIndex:0];
    id row = [[space objectForKey:@"data"] lastObject];
    
    id cursor = [NSNull null];
    if (row != nil)
        cursor = [row objectForKey:@"cursor"];
    
    [self loadData:rowcountField.selectedTag from:cursor search:searchField.stringValue];
}

- (IBAction)prev:(id)sender {
    if ([spacesController.selectedObjects count] < 1)
        return;
    
    NSDictionary *space = [spacesController.selectedObjects objectAtIndex:0];
    id row = [[space objectForKey:@"data"] firstObject];
    
    id cursor = [NSNull null];
    if (row != nil)
        cursor = [row objectForKey:@"cursor"];
    
    [self loadData:-rowcountField.selectedTag from:cursor search:searchField.stringValue];
}

- (void)controlTextDidChange:(NSNotification *)obj {
    if ([obj object] == searchField) {
        [self loadData:rowcountField.selectedTag
                  from:[NSNull null]
                search:searchField.stringValue];
    }
}
- (void)rowcount:(id)sender { 
    [self loadData:rowcountField.selectedTag
              from:[NSNull null]
            search:searchField.stringValue];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn
            row:(NSInteger)row {
    if ([connectionsController.selectedObjects count] < 1)
        return nil;
    
    if ([spacesController.selectedObjects count] < 1)
        return nil;
    
    NSDictionary *space = [spacesController.selectedObjects objectAtIndex:0];
    
    // Lua array start from 1
    NSUInteger field = [[tableView tableColumns] indexOfObject:tableColumn] + 1;
    
    return [[[space objectForKey:@"data"] objectAtIndex:row]
            objectForKey:[NSNumber numberWithInteger:field]];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if ([connectionsController.selectedObjects count] < 1)
        return 0;
    
    if ([spacesController.selectedObjects count] < 1)
        return 0;
    
    NSDictionary *space = [spacesController.selectedObjects objectAtIndex:0];
    
    return [[space objectForKey:@"data"] count];
}

- (void)tableView:(NSTableView *)tableView
   setObjectValue:(id)object
   forTableColumn:(NSTableColumn *)tableColumn
              row:(NSInteger)row {
    
    if ([connectionsController.selectedObjects count] < 1)
        return;
    
    if ([spacesController.selectedObjects count] < 1)
        return;
    
    NSDictionary *conn = [connectionsController.selectedObjects objectAtIndex:0];
    
    if ([[conn objectForKey:@"state"] intValue] != CONNECTED)
        return;
    
    dispatch_queue_t serialTntQueue = [conn objectForKey:@"tnt_queue"];
    struct tnt_stream *tnt = [(NSTntStream*)[conn objectForKey:@"tnt_stream"] tnt];
    
    NSDictionary *space = [spacesController.selectedObjects objectAtIndex:0];
    
    id origin = [[space objectForKey:@"data"] objectAtIndex:row];
    id newobj = [origin mutableCopy];
    
    // Lua array starts from 1
    NSNumber *field = [NSNumber numberWithUnsignedInteger:[[tableView tableColumns] indexOfObject:tableColumn] + 1];
    [newobj setObject:object forKey:field];
    
    dispatch_async(serialTntQueue, ^{
        NSMutableArray *result = alterData(tnt, [space objectForKey:@"name"], origin,
                                           newobj);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[result objectAtIndex:0] isKindOfClass:NSNull.class]) {
                NSLog(@"%@", [result objectAtIndex:1]);
                [self alert:[NSString stringWithFormat:@"%@", [result objectAtIndex:1]]
                     window:[self->dataView window]];
                return;
            }
            
            [[space objectForKey:@"data"] setObject:[result objectAtIndex:0] atIndexedSubscript:row];
            
            NSRange columns = NSMakeRange(0, [[self->dataView tableColumns] count]);
            
            [self->dataView reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:row]
                                columnIndexes:[NSIndexSet indexSetWithIndexesInRange:columns]];
        });
    });
}

- (void) alert:(NSString*)message window:(NSWindow*)window {
    NSAlert *msg = [NSAlert new];
    [msg addButtonWithTitle:@"Ok"];
    [msg setMessageText:@"Error"];
    [msg setInformativeText:message];
    [msg beginSheetModalForWindow:window completionHandler:nil];
}
@end
