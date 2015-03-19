//
//  SettingsWindowViewController.m
//  Whitebox
//
//  Created by Olegs on 19/02/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import "SettingsWindowViewController.h"

@interface SettingsWindowViewController ()

@property (weak) IBOutlet NSTableView *plugin_table_view;
@property (weak) IBOutlet NSView      *form_template_view;
@property (weak) IBOutlet NSTabView   *tab_view;

@end

@implementation SettingsWindowViewController

- (void) viewDidLoad {
    [super viewDidLoad];
}

//- (IBAction)performClick:(id)sender {
//    NSLog(@"Hello there!");
//}

//- (void) tableView:(NSTableView *)table_view didClickTableColumn:(NSTableColumn *)table_column {
//    NSLog(@"table column: %@", table_column);
//}

//- (void) tableViewSelectionDidChange:(NSNotification *)notification {
//    NSLog(@"maybe here?");
//    NSLog(@"Notification: %@", notification);
//}

- (NSInteger) numberOfRowsInTableView:(NSTableView *)table_view {
    
    NSLog(@"Hello!");
    
    NSLog(@"Plugins count: %lu", (unsigned long)[self.plugins count]);
    
    return self.plugins == nil ? 0 : [self.plugins count];
}

- (NSView *)tableView:(NSTableView *)table_view viewForTableColumn:(NSTableColumn *)table_column row:(NSInteger)index {
    
    NSLog(@"Rendering a table view");
    
    ReactorPlugin *plugin = [self.plugins objectAtIndex:index];
    
    if (plugin == nil) {
        return nil;
    }
    
    NSTableCellView *cell = [table_view makeViewWithIdentifier:@"PluginTableCell" owner:self];
    
    NSLog(@"Cell view: %@", cell);
    
    cell.textField.stringValue = plugin.name;
    
    return cell;
}

- (void) buildPluginSettingsView {
    
    if (self.plugins == nil) {
        self.plugins = [[NSMutableArray alloc] init];
    }
    
    NSStackView *stack_view = (NSStackView *)[self.form_template_view getSubviewByIdentifier:@"StackView"];
    
    [self.tab_view setSubviews:[NSArray array]];
    
    for (ReactorPlugin *plugin in [PluginManager plugins]) {
        id<ReactorPluginViewBuilder> v_builder = [plugin getViewBuilder];
        if ([v_builder respondsToSelector:@selector(hasSettingsPane)] &&
            [v_builder hasSettingsPane]) {
            
            NSDictionary *settings_elements = [v_builder settingsPaneElements];
            if (settings_elements == nil) {
                continue;
            }
            NSLog(@"Settings elements: %@", settings_elements);
            
            NSTabViewItem *tab_view_item = [[NSTabViewItem alloc] init];
            
            NSStackView *tab_cell_view = (NSStackView *)[stack_view copyWithConstraints];
            
            int ix = 0;
            
            for (NSString *element_name in settings_elements) {
                NSString *element_type = [settings_elements valueForKey:element_name];
                NSString *settings_key = [NSString stringWithFormat:@"StoragePlugins.%@.%@",
                                          [plugin signature],
                                          element_name];
                id current_value = [WhiteBox valueForPathKey:settings_key];
                
                NSLog(@"Key: %@, Type: %@, Value: %@", settings_key, element_type, current_value);
                
                [tab_cell_view insertView:[self buildElementOfType:element_type Name:element_name Value:current_value] atIndex:ix inGravity:NSStackViewGravityLeading];
                ix++;
            }
            
            [self.plugins addObject:plugin];
            
            
            [tab_view_item.view addSubview:tab_cell_view];
            
            [self.tab_view addTabViewItem:tab_view_item];
        }
    }
    
    NSLog(@"Will reload table data");
    
    NSLog(@"Size: %f, %f, %f, %f",
                        self.plugin_table_view.frame.origin.x,
                        self.plugin_table_view.frame.origin.y,
                        self.plugin_table_view.frame.size.width,
                        self.plugin_table_view.frame.size.height);

    [self.plugin_table_view reloadData];
}

NSDictionary *_form_element_prototypes = nil;

- (NSView *) /*FIX ME*/ buildElementOfType:(NSString *)type Name:(NSString *)name Value:(id)value {
    
    if (_form_element_prototypes == nil) {
        _form_element_prototypes = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    [self.form_template_view copySubviewWithIdentifier:@"Text"], @"text",
                                    [self.form_template_view copySubviewWithIdentifier:@"Password"], @"password",
                                    [self.form_template_view copySubviewWithIdentifier:@"Number"], @"int",
                                    [self.form_template_view copySubviewWithIdentifier:@"Set"], @"set",
                                    [self.form_template_view copySubviewWithIdentifier:@"Bool"], @"bool",
                                    nil];
    }
    
    NSView *proto = [_form_element_prototypes objectForKey:type];
    
    if (proto == nil) {
        NSLog(@"Unable to find a prototype for field type %@", type);
        return nil;
    }
    
    NSView *control = [proto copyWithConstraints];
    
    // TODO
    
    if ([control respondsToSelector:@selector(setStringValue:)]) {
        if ([value class] == [NSString class]) {
            [control performSelector:@selector(setStringValue:) withObject:value];
        }
    }
    
    return control;
}

@end
