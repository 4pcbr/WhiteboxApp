//
//  RESTViewBuilder.m
//  Whitebox
//
//  Created by Olegs on 18/01/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import "RESTViewBuilder.h"

#define MY_STORAGE_PLUGUN         "RESTStoragePlugin"
#define LOCAL_FILE_STORAGE_PLUGIN "LocalFileStoragePlugin"

@implementation RESTViewBuilder

- (BOOL) hasMenuItem:(Capture *)capture {
    return YES;
}

- (NSMenuItem *) buildMenuItem:(Capture *)capture {
    
    CaptureData *capture_data = [self getCaptureData:capture forProvider:@MY_STORAGE_PLUGUN];
    NSString    *title;
    SEL          selector;
    NSMenuItem  *menu_item = [[NSMenuItem alloc] init];
    
    if (capture_data == nil) {
        
        CaptureData *local_file_storage_data = [self getCaptureData:capture forProvider:@LOCAL_FILE_STORAGE_PLUGIN];
        
        if (local_file_storage_data == nil) {
            // Unable to re-upload file
            title = [NSString stringWithFormat:NSLocalizedString(@"PLUGIN_REST_UNABLE_UPLOAD", nil), self.hostname];
            selector = nil;
        } else {
            title = [NSString stringWithFormat:NSLocalizedString(@"PLUGIN_REST_REUPLOAD", nil), self.hostname];
            selector = @selector(reuploadFileDidClick:);
        }
    } else {
        title = [NSString stringWithFormat:NSLocalizedString(@"PLUGIN_REST_OPEN", nil), [self hostname]];
        selector = @selector(menuItemDidClick:);
    }
    
    menu_item.target            = self;
    menu_item.action            = selector;
    menu_item.title             = title;
    menu_item.representedObject = capture;
    
    return menu_item;
}

- (void) reuploadFileDidClick:(id)sender {
    
    Capture *capture = (Capture *)[sender representedObject];
    
    if (capture == nil) {
        NSLog(@"No capture record found. Omitting.");
        // TODO: alert user
        return;
    }
    
    NSObject <NSApplicationDelegate, ReactorDelegate> *delegate = (NSObject<NSApplicationDelegate, ReactorDelegate> *)[[NSApplication sharedApplication] delegate];
    
    Session *session = [SessionManager createSession];
    
    NSMutableDictionary *shared_context = [[NSMutableDictionary alloc] init];
    [shared_context setValue:capture               forKey:@SHRD_CTX_CAPTURE_MNGD_OBJ];
    
    [session setContext:shared_context];
    [session setEventID:RE_REQUEST_RESTORE_FH];
    
    [delegate emitEvent:RE_REQUEST_RESTORE_FH session:session].then(^(NSData *data) {
        [delegate emitEvent:RE_PLUGIN_REST_UPLOAD session:session].then(^(NSData *sub_data) {
            [SessionManager expireSessionBySSID:session.ssid];
            [delegate emitEvent:RE_EOC session:nil];
        }).catch(^(NSError *sub_error) {
            // TODO
        });
    }).catch(^(NSError *error) {
        // TODO
    });
}

- (CaptureData *) getCaptureData:(Capture *)capture forProvider:(NSString *)provider {
    NSString *predicate_tmpl = [NSString stringWithFormat:@"provider=\"%@\"", provider];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicate_tmpl];
    CaptureData *capture_data = [capture getCaptureDataInstanceWithPredicate:predicate];
    
    return capture_data;
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
