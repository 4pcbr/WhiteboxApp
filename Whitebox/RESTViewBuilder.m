//
//  RESTViewBuilder.m
//  Whitebox
//
//  Created by Olegs on 18/01/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import "RESTViewBuilder.h"

@implementation RESTViewBuilder

- (BOOL) hasMenuItem:(Capture *)capture {
    return YES;
}

- (NSMenuItem *) buildMenuItem:(Capture *)capture {
    NSMenuItem *menu_item = [[NSMenuItem alloc] init];
    menu_item.title = self.hostname;
    menu_item.action = @selector(menuItemDidClick:);
    menu_item.target = self;
    menu_item.representedObject = capture;
    return menu_item;
}

- (void) menuItemDidClick:(id)sender {
    Capture *capture = (Capture *)[sender representedObject];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"provider=\"RESTStoragePlugin\""];
    CaptureData *capture_data = [capture getCaptureDataInstanceWithPredicate:predicate];
    NSLog(@"%@", capture_data);
    if (capture_data != nil) {
        NSString *meta = [capture_data meta];
        NSLog(@"url: %@", meta);
        if (meta != nil) {
            [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:meta]];
            return; // <=== exit the function if the URL exists
        }
    }
    
    // @FIXME
    // Here we'd better reupload the file
    
    NSString *alert_msg = NSLocalizedString(@"The item is empty.", nil);
    NSString *okButton = NSLocalizedString(@"OK", nil);
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:alert_msg];
    [alert addButtonWithTitle:okButton];
    [alert runModal];
    
    // @END_OF_FIXME
}

@end
