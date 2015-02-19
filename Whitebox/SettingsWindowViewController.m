//
//  SettingsWindowViewController.m
//  Whitebox
//
//  Created by Olegs on 19/02/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import "SettingsWindowViewController.h"

@interface SettingsWindowViewController ()

@property (weak) IBOutlet NSView *plugin_settings_pane;

@end

@implementation SettingsWindowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void) buildPluginSettingsView {
    
    for (ReactorPlugin *plugin in self.plugins) {
        id<ReactorPluginViewBuilder> v_builder = [plugin getViewBuilder];
        if ([v_builder respondsToSelector:@selector(hasSettingsPane)] &&
            [v_builder hasSettingsPane]) {
            NSDictionary *settings_elements = [v_builder settingsPaneElements];
            if (settings_elements == nil) {
                continue;
            }
            NSLog(@"Settings elements: %@", settings_elements);
            for (NSString *element_name in settings_elements) {
                NSString *element_type = [settings_elements valueForKey:element_name];
                NSString *settings_key = [NSString stringWithFormat:@"StoragePlugins.%@.%@",
                                          [plugin signature],
                                          element_name];
                id current_value = [WhiteBox valueForPathKey:settings_key];
//                NSLog(@"Current value for key %@: %@, type: %@", settings_key, current_value, element_type);
                [self buildElementOfType:element_type Name:settings_key Value:current_value];
            }
        }
    }
}

- (void) /*FIX ME*/ buildElementOfType:(NSString *)type Name:(NSString *)name Value:(id)value {
    // TODO
}

@end
