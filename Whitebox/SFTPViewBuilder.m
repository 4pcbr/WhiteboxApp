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
    
    Capture *capture = (Capture *)[sender representedObject];
    
    if (capture == nil) {
        NSLog(@"No capture record found. Omitting.");
        // TODO: alert user
        return;
    }
    
    NSObject <NSApplicationDelegate, ReactorDelegate> *delegate = (NSObject<NSApplicationDelegate, ReactorDelegate> *)[[NSApplication sharedApplication] delegate];
    
    NSLog(@"Delegate: %@", delegate);
    
    Session *session = [SessionManager createSession];
    
    NSMutableDictionary *shared_context = [[NSMutableDictionary alloc] init];
    [shared_context setValue:capture               forKey:@SHRD_CTX_CAPTURE_MNGD_OBJ];
    
    [session setContext:shared_context];
    [session setEventID:RE_REQUEST_RESTORE_FH];
    
    [delegate emitEvent:RE_REQUEST_RESTORE_FH session:session].then(^(NSData *data) {
        
        NSLog(@"Session file path: %@", [[session context] valueForKey:@SHRD_CTX_TMP_FILE_FULL_PATH]);
        
        [delegate emitEvent:RE_PLUGIN_SFTP_UPLOAD session:session].then(^(NSData *sub_data) {
            [SessionManager expireSessionBySSID:session.ssid];
            [delegate emitEvent:RE_EOC session:nil];
        }).catch(^(NSError *sub_error) {
            // TODO
        });
        
        NSLog(@"Session context: %@", session.context);
        
    }).catch(^(NSError *error) {
    });
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

- (BOOL) hasSettingsPane {
    return YES;
}

- (NSDictionary *) settingsPaneElements {
    return @{
             @"Enabled": @"checkbox",
             @"Host": @"text",
             @"Port": @"int",
             @"User": @"text",
             @"Password": @"password",
             @"PrivateKey": @"text",
             @"PublicKey": @"text",
             @"WebPort": @"int",
             @"WebSchema": @"text",
             @"ScriptFilePath": @"text"
             };
}

@end
