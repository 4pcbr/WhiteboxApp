//
//  SFTPStpragePlugin.m
//  Whitebox
//
//  Created by Olegs on 21/01/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import "SFTPStpragePlugin.h"

#define SFTP_SCRIPT_GET_STORAGE_PATH_F_CALL "window.SFTPStoragePlugin.getStoragePath(\"%@\");"
#define SFTP_SCRIPT_GET_WEB_PATH_F_CALL     "window.SFTPStoragePlugin.getWebPath(\"%@\", \"%@\", \"%@\");"

@implementation SFTPStpragePlugin

- (BOOL) canHandleEvent:(int)event_id forSession:(Session *)session {
    
    if (event_id != RE_SCREEN_CAPTURE_CREATED) {
        NSLog(@"Don't know how to handle an event with this ID");
        return NO;
    };
    
    Capture *capture = [[session context] valueForKey:@SHRD_CTX_CAPTURE_MNGD_OBJ];
    
    if (!capture) {
        NSLog(@"No capture in the reactor data provided");
        return NO;
    }
    
    if (capture.type.intValue != CAPTURE_TYPE_SCREEN_IMG) {
        NSLog(@"Non-image type capture provided");
        return NO;
    }
    
    return YES;
}

- (PMKPromise *) run:(Session *) session {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        // @TODO: Validate these values, it's not safe to use 'em in JS
        NSString     *host    = [self->options valueForKey:@"Host"];
        NSString     *port    = [self->options valueForKey:@"Port"];
        NSString     *user    = [self->options valueForKey:@"User"];
        
        NSDictionary *session_context     = [session context];
        NSFileHandle *input_file          = [session_context valueForKey:@SHRD_CTX_TMP_FILE_HANDLE];
        NSString     *yyyymmddhhiiss_name = [session_context valueForKey:@SHRD_CTX_YYYYMMDDHHIISS_FILE_NAME];
        
        NMSSHSession *session = [NMSSHSession connectToHost:host port:port withUsername:user];
        
        if ([session isConnected]) {
        
            WebView *web_view = [WhiteBox valueForPathKey:@"Sandbox.Web.JS"];
            NSString *storage_path = [web_view stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@SFTP_SCRIPT_GET_STORAGE_PATH_F_CALL, yyyymmddhhiiss_name]];
            
            BOOL success = session.channel uploadFile:<#(id)#> to:<#(id)#>
            
            [session disconnect];
            
            fulfill(session);
        } else {
            reject(fulfill);
            [session disconnect];
            
        }
    }];
}

- (id<ReactorPluginViewBuilder>) getViewBuilder {
//    if (self->view_builder == NULL) {
//        RESTViewBuilder *vb = [[RESTViewBuilder alloc] init];
//        vb.hostname = [self->options objectForKey:@"Host"];
//        self->view_builder = vb;
//    }
//    return self->view_builder;
    return nil;
}

@end
