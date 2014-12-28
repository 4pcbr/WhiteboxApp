//
//  CaptureViewBuilder.m
//  Whitebox
//
//  Created by Olegs on 26/12/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import "CaptureViewBuilder.h"

@implementation CaptureViewBuilder

+ (NSMenuItem *) buildMenuItem:(Capture *)capture {
    NSMenuItem *menu_item = [[NSMenuItem alloc] init];
    
    switch (capture.type.intValue) {
        case CAPTURE_TYPE_SCREEN_IMG:;
            NSDateFormatter *date_formatter = [[NSDateFormatter alloc] init];
            NSDate *created_at = capture.created_at;
            [date_formatter setDateFormat:[WhiteBox valueForPathKey:@"View.Menu.Date.Format"]];
            NSString *title = [date_formatter stringFromDate:created_at];
            menu_item.title = title;
            NSMenu *sub_menu = [self buildSubMenu:capture];
            [menu_item setSubmenu:sub_menu];
            break;
//        default:
//            break;
    }
    
    return menu_item;
}

+ (NSMenu *) buildSubMenu:(Capture *)capture {
    NSMenu *sub_menu = [[NSMenu alloc] init];
    [sub_menu setAutoenablesItems:YES];
    for (ReactorPlugin *plugin in [PluginManager plugins]) {
        if ([plugin isEnabled]) {
            id<ReactorPluginViewBuilder> view_builder = [plugin getViewBuilder];
            if ([view_builder hasMenuItem:capture]) {
                NSMenuItem *sub_menu_item = [view_builder buildMenuItem:capture];
                [sub_menu addItem:sub_menu_item];
            }
        }
    }
    return sub_menu;
}

@end
