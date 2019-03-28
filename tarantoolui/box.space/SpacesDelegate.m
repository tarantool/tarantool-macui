//
//  SpacesDelegate.m
//  tarantoolui
//
//  Created by Michael Filonenko on 08/03/2019.
//  Copyright © 2019 tarantool. All rights reserved.
//

#import "SpacesDelegate.h"

#import "ConnectionsDelegate.h"

#import "Common.h"
#import "GetSpaces.h"
#import "GetData.h"


#import "../box.schema/FieldTypesDataSource.h"

@implementation SpacesDelegate

@synthesize searchPanel;

@synthesize editor;

@synthesize spacesController;
@synthesize spacesView;

@synthesize connectionsController;

@synthesize settingsPanel;

@synthesize createSpaceWindow;
@synthesize createSpaceGuard;
@synthesize createSpaceDelegate;

@synthesize dropSpaceWindow;
@synthesize dropSpaceGuard;
@synthesize dropSpaceDelegate;

@synthesize name;

- (void)awakeFromNib {
    [super awakeFromNib];
    NSArray *namePath = @[[NSExpression expressionForKeyPath:@"name"]];
    NSArray *operators = @[@(NSEqualToPredicateOperatorType),
                           @(NSNotEqualToPredicateOperatorType),
                           @(NSBeginsWithPredicateOperatorType),
                           @(NSEndsWithPredicateOperatorType),
                           @(NSContainsPredicateOperatorType),
                           @(NSLikePredicateOperatorType),
                           @(NSMatchesPredicateOperatorType)];
    NSArray *equalOperator = @[@(NSEqualToPredicateOperatorType)];
    NSArray *intOperators = @[@(NSEqualToPredicateOperatorType),
                           @(NSNotEqualToPredicateOperatorType),
                              @(NSLessThanPredicateOperatorType),
                              @(NSLessThanOrEqualToPredicateOperatorType),
                              @(NSGreaterThanPredicateOperatorType),
                              @(NSGreaterThanOrEqualToPredicateOperatorType),
                           ];
    
    NSPredicateEditorRowTemplate *nameTemplate = [[NSPredicateEditorRowTemplate alloc]
                                              initWithLeftExpressions:namePath
                                              rightExpressionAttributeType:NSStringAttributeType
                                              modifier:NSDirectPredicateModifier
                                              operators:operators
                                              options:(NSCaseInsensitivePredicateOption | NSDiacriticInsensitivePredicateOption)];
    
    NSArray *enginePath = @[[NSExpression expressionForKeyPath:@"engine"]];
    NSArray *engineConsts = @[[NSExpression expressionForConstantValue:@"memtx"],
                              [NSExpression expressionForConstantValue:@"vinyl"]];
    NSPredicateEditorRowTemplate *engineTemplate = [[NSPredicateEditorRowTemplate alloc]
                                                  initWithLeftExpressions:enginePath
                                                  rightExpressions:engineConsts
                                                  modifier:NSDirectPredicateModifier
                                                  operators:equalOperator
                                                  options:(NSCaseInsensitivePredicateOption | NSDiacriticInsensitivePredicateOption)];
    
    NSArray *boolPropPath = @[[NSExpression expressionForKeyPath:@"is_local"],
                              [NSExpression expressionForKeyPath:@"temporary"],
                              [NSExpression expressionForKeyPath:@"enabled"]];
    
    NSArray *boolPropConsts = @[[NSExpression expressionForConstantValue:[NSNumber numberWithInt:1]],
                              [NSExpression expressionForConstantValue:[NSNumber numberWithInt:0]]];
    NSPredicateEditorRowTemplate *boolPropTemplate = [[NSPredicateEditorRowTemplate alloc]
                                                    initWithLeftExpressions:boolPropPath
                                                    rightExpressions:boolPropConsts
                                                    modifier:NSDirectPredicateModifier
                                                    operators:equalOperator
                                                    options:0];
    
    NSArray *intPropPath = @[[NSExpression expressionForKeyPath:@"id"],
                             [NSExpression expressionForKeyPath:@"field_count"],];
    
    NSPredicateEditorRowTemplate *intPropTemplate =
    [[NSPredicateEditorRowTemplate alloc]
     initWithLeftExpressions:intPropPath
 rightExpressionAttributeType:NSInteger64AttributeType
                modifier:NSDirectPredicateModifier
            operators:intOperators
                options:0];
 
    NSArray *compoundTypes = @[@(NSAndPredicateType),
                               @(NSOrPredicateType),
                               @(NSNotPredicateType),];
    NSPredicateEditorRowTemplate *compound = [[NSPredicateEditorRowTemplate alloc] initWithCompoundTypes:compoundTypes];
    
    [editor setRowTemplates:@[nameTemplate, engineTemplate, boolPropTemplate,
                              intPropTemplate,
                              compound]];
    
    [connectionsController addObserver:self
                            forKeyPath:@"selection"
                               options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
                               context:NULL];
    [connectionsController addObserver:self
                            forKeyPath:@"arrangedObjects.state"
                               options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
                               context:NULL];
    
    [spacesController addObserver:self
                            forKeyPath:@"selection"
                               options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew
                               context:NULL];
}

- (void)openFilterEditor:(nonnull id)sender {
    [searchPanel orderFront:[sender window]];
}

- (IBAction)add:(id)sender {
    if ([connectionsController.selectedObjects count] < 1)
        return;
    
    NSDictionary *conn = [connectionsController.selectedObjects objectAtIndex:0];
    if ([[conn objectForKey:@"state"] intValue] != CONNECTED)
        return;
    
    if (createSpaceWindow == nil) {
        NSArray *objects;
        [[NSBundle mainBundle] loadNibNamed:@"CreateSpace" owner:self topLevelObjects:&objects];
        createSpaceGuard = objects;
        createSpaceDelegate.spacesController = spacesController;
    }
    
    createSpaceDelegate.selectedConnection = conn;
    
    createSpaceDelegate.isnew = YES;
    createSpaceDelegate.createSpaceObject.content = [NSMutableDictionary
                                 dictionaryWithDictionary:@{@"engine":@"memtx",
                                                            @"format":[NSMutableArray array],
                                                            @"temporary":[NSNumber numberWithBool:NO],
                                                            @"is_local":[NSNumber numberWithBool:NO],
                                                            }];
    
    [NSApp beginSheet:createSpaceWindow
       modalForWindow:[spacesView window]
        modalDelegate:nil
       didEndSelector:nil
          contextInfo:nil];
    
}

- (IBAction)modify:(id)sender {
    if ([connectionsController.selectedObjects count] < 1)
        return;
    
    NSDictionary *conn = [connectionsController.selectedObjects objectAtIndex:0];
    if ([[conn objectForKey:@"state"] intValue] != CONNECTED)
        return;
    
    if ([spacesController.selectedObjects count] < 1)
        return;
    
    if (createSpaceWindow == nil) {
        NSArray *objects;
        [[NSBundle mainBundle] loadNibNamed:@"CreateSpace" owner:self topLevelObjects:&objects];
        createSpaceGuard = objects;
        createSpaceDelegate.spacesController = spacesController;
    }
    
    createSpaceDelegate.selectedConnection = conn;
    
    createSpaceDelegate.isnew = NO;
    NSMutableDictionary *space = [spacesController.selectedObjects objectAtIndex:0];
    createSpaceDelegate.origin = space;
    
    createSpaceDelegate.createSpaceObject.content = [space mutableDeepCopy];
    
    [NSApp beginSheet:createSpaceWindow
       modalForWindow:[spacesView window]
        modalDelegate:nil
       didEndSelector:nil
          contextInfo:nil];
    
}

- (IBAction)remove:(id)sender {
    if ([connectionsController.selectedObjects count] < 1)
        return;
    
    NSDictionary *conn = [connectionsController.selectedObjects objectAtIndex:0];
    if ([[conn objectForKey:@"state"] intValue] != CONNECTED)
        return;
    
    if (dropSpaceWindow == nil) {
        NSArray *objects;
        [[NSBundle mainBundle] loadNibNamed:@"DropSpace" owner:self topLevelObjects:&objects];
        dropSpaceGuard = objects;
        dropSpaceDelegate.objectsController = spacesController;
        dropSpaceDelegate.selectedConnection = conn;
    }
    
    [NSApp beginSheet:dropSpaceWindow
       modalForWindow:[spacesView window]
        modalDelegate:nil
       didEndSelector:nil
          contextInfo:nil];
}

- (void) alert:(NSString*)message {
    NSAlert *msg = [NSAlert new];
    [msg addButtonWithTitle:@"Ok"];      // 1st button
    [msg setMessageText:@"Error"];
    [msg setInformativeText:message];
    [msg beginSheetModalForWindow:[spacesView window] modalDelegate:nil didEndSelector:nil contextInfo:NULL];
}

- (void)controlTextDidEndEditing:(NSNotification *)notification {
    NSLog(@"%@", notification);
    if ([[notification object] isKindOfClass:NSTextField.class]) {
        NSString *str = [(NSTextField*)[notification object] objectValue];
        @try {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:str];
            spacesController.filterPredicate = predicate;
        } @catch(...) {
            
        }
    }
}

- (void)refresh:(id)sender {
    if ([connectionsController.selectedObjects count] < 1)
        return;
    
    NSMutableDictionary *conn = [connectionsController.selectedObjects objectAtIndex:0];
    
    if ([[conn objectForKey:@"state"] intValue] != CONNECTED)
        return;
    
    dispatch_queue_t serialTntQueue = [conn objectForKey:@"tnt_queue"];
    struct tnt_stream *tnt = [(NSTntStream*)[conn objectForKey:@"tnt_stream"] tnt];
    
    BOOL showSystem = [[NSUserDefaults standardUserDefaults] boolForKey:@"show-system-spaces"];

    dispatch_async(serialTntQueue, ^{
        NSMutableArray *result = getSpaces(tnt, showSystem);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[result objectAtIndex:0] isKindOfClass:NSNull.class]) {
                [self alert:[result objectAtIndex:1]];
                return;
            }
            
            [conn setObject:[result objectAtIndex:0] forKey:@"schema"];
        });
    });
}

- (IBAction)settingsAction:(id)sender {
    [NSApp beginSheet:settingsPanel modalForWindow:[spacesView window]
        modalDelegate:self
       didEndSelector:@selector(settingsEndAction:)
          contextInfo:NULL];
}

- (IBAction)settingsEndAction:(id)sender {
    [settingsPanel orderOut:[settingsPanel parentWindow]];
    [NSApp endSheet:settingsPanel returnCode:0];
    [self refresh:sender];
}


-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                      context:(void *)context {
    if (object == connectionsController) {
        [self connectionSelected];
    } else if (object == spacesController) {
        if ([[spacesController selectedObjects] count] < 1)
            return;
        
        name.stringValue = [[spacesController.selectedObjects objectAtIndex:0] objectForKey:@"name"];
    }
}

- (void)connectionSelected {
    if ([connectionsController.selectedObjects count] < 1)
        return;
    
    NSMutableDictionary *conn = [connectionsController.selectedObjects objectAtIndex:0];
    
    if ([[conn objectForKey:@"state"] intValue] != CONNECTED)
        return;
    
    if ([conn objectForKey:@"schema"] != nil)
        return;
    
    [self refresh: nil];
}

@end
