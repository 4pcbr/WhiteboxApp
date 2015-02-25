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

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSInteger) numberOfRowsInTableView:(NSTableView *)tableView {
    
    NSLog(@"Plugins count: %lu", (unsigned long)[self.plugins count]);
    
    return self.plugins == nil ? 0 : [self.plugins count];
}

- (NSView *)tableView:(NSTableView *)table_view viewForTableColumn:(NSTableColumn *)table_column row:(NSInteger)index {
    
    ReactorPlugin *plugin = [self.plugins objectAtIndex:index];
    
    NSLog(@"Plugin is being rendered as a cell view: %@", plugin);
    
    if (plugin == nil) {
        return nil;
    }
    
    NSTableCellView *cell = [table_view makeViewWithIdentifier:@"PluginCellView" owner:self.plugin_table_view];
    
    NSLog(@"Cell view: %@", cell);
    
    cell.textField.stringValue = plugin.name;
    
    return cell;
}

//- (id)tableView:(NSTableView *)table_view objectValueForTableColumn:(NSTableColumn *)column row:(NSInteger)index {
//    
//    
//    NSTextField *text_field = [table_view makeViewWithIdentifier:@"PluginViewCell" owner:self];
//    
//    NSLog(@"text field: %@", text_field);
//    
//    
//    
//    NSLog(@"String value: %@", plugin.signature);
//    
//    return text_field;
//}


- (void) buildPluginSettingsView {
    
    if (self.plugins == nil) {
        self.plugins = [[NSMutableArray alloc] init];
    }
    
    NSStackView *stack_view = (NSStackView *)[self.form_template_view getSubviewByIdentifier:@"StackView"];
    
    NSLog(@"StackView: %@", stack_view);
    
    for (ReactorPlugin *plugin in [PluginManager plugins]) {
        id<ReactorPluginViewBuilder> v_builder = [plugin getViewBuilder];
        if ([v_builder respondsToSelector:@selector(hasSettingsPane)] &&
            [v_builder hasSettingsPane]) {
            
            NSDictionary *settings_elements = [v_builder settingsPaneElements];
            if (settings_elements == nil) {
                continue;
            }
            NSLog(@"Settings elements: %@", settings_elements);
            
//            for (NSString *element_name in settings_elements) {
//                NSString *element_type = [settings_elements valueForKey:element_name];
//                NSString *settings_key = [NSString stringWithFormat:@"StoragePlugins.%@.%@",
//                                          [plugin signature],
//                                          element_name];
//                id current_value = [WhiteBox valueForPathKey:settings_key];
//            }
            
//            [self.pluginController addObject:plugin];
            [self.plugins addObject:plugin];
            
            NSTabViewItem *tab_view_item = [[NSTabViewItem alloc] init];
            
            NSStackView *tab_cell_view = (NSStackView *)[stack_view copyWithConstraints];
            
            [tab_view_item.view addSubview:tab_cell_view];
            
            [self.tab_view addTabViewItem:tab_view_item];
        }
    }
    
    NSLog(@"Will reload table data");
    
    [self.plugin_table_view reloadData];
    
//    self.tab_view.tabViewItems
}

- (NSTableCellView *) /*FIX ME*/ buildElementOfType:(NSString *)type Name:(NSString *)name Value:(id)value {
    // TODO
    NSTextFieldCell *text_cell = [[NSTextFieldCell alloc] initTextCell:NSLocalizedString(name, nil)];
    NSTextField *text_field = [[NSTextField alloc]init];
    [text_field setCell:text_cell];
    NSTableCellView *cell_view = [[NSTableCellView alloc] init];
    [cell_view setTextField:text_field];

    return cell_view;
}

@end
