//
//  LocalFileViewBuilder.m
//  Whitebox
//
//  Created by Olegs on 28/12/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import "LocalFileViewBuilder.h"

@implementation LocalFileViewBuilder

- (BOOL) hasMenuItem:(Capture *)capture {
    return YES;
}

- (NSMenuItem *) buildMenuItem:(Capture *)capture {
    NSMenuItem *menu_item = [[NSMenuItem alloc] init];
    menu_item.title = NSLocalizedString(@"REVEAL_IN_FINDER", nil);
    menu_item.action = @selector(menuItemDidClick:);
    menu_item.target = self;
    menu_item.representedObject = capture;
    return menu_item;
}

- (void)menuItemDidClick:(id)sender {
    Capture *capture = (Capture *)[sender representedObject];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"provider=\"LocalFileStoragePlugin\""];
    CaptureData *capture_data = [capture getCaptureDataInstanceWithPredicate:predicate];
    if (capture_data != nil) {
        NSString *meta = [capture_data meta];
        if (meta != nil) {
            NSURL *file_URL = [NSURL fileURLWithPath:meta];
            NSArray *file_URLs = [NSArray arrayWithObjects:file_URL, nil];
            [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:file_URLs];
        }
    }
}

@end
