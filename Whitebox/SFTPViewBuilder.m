//
//  SFTPViewBuilder.m
//  Whitebox
//
//  Created by Olegs on 21/01/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import "SFTPViewBuilder.h"

@implementation SFTPViewBuilder

- (BOOL) hasMenuItem:(Capture *)capture {
    return YES;
}

- (NSMenuItem *) buildMenuItem:(Capture *)capture {
    CaptureData *capture_data = [self getCaptureData:capture forProvider:@"SFTPStoragePlugin"];
    NSMenuItem *menu_item = [[NSMenuItem alloc] init];
    
    if (capture_data == nil) {
        // let's check if we have a local_file
        CaptureData *local_file_capture_data = [self getCaptureData:capture forProvider:@"LocalFileStoragePlugin"];
        
        if (local_file_capture_data == nil) {
            // ok, we have no local file
            // we can't reupload it
            menu_item.title  = [NSString stringWithFormat:NSLocalizedString(@"PLUGIN_SFTP_UNABLE_UPLOAD", nil), self.hostname];
            menu_item.action = nil;
        } else {
            // we can reupload the file
            menu_item.title  = [NSString stringWithFormat:NSLocalizedString(@"PLUGIN_SFTP_REUPLOAD", nil), self.hostname];
            menu_item.action = @selector(reuploadFileDidClick:);
        }
    } else {
        menu_item.title  = [NSString stringWithFormat:NSLocalizedString(@"PLUGIN_SFTP_OPEN", nil), [self hostname]];
        menu_item.action = @selector(menuItemDidClick:);
    }

    menu_item.target = self;
    menu_item.representedObject = capture;

    return menu_item;
}

- (CaptureData *) getCaptureData:(Capture *)capture forProvider:(NSString *)provider {
    NSString *predicate_tmpl = [NSString stringWithFormat:@"provider=\"%@\"", provider];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicate_tmpl];
    CaptureData *capture_data = [capture getCaptureDataInstanceWithPredicate:predicate];
    
    return capture_data;
}

- (void) reuploadFileDidClick:(id)sender {
    // TODO
}

- (void) menuItemDidClick:(id)sender {
    Capture *capture = (Capture *)[sender representedObject];
    CaptureData *capture_data = [self getCaptureData:capture forProvider:@"SFTPStoragePlugin"];
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
}

@end
