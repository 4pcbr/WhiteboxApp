//
//  SFTPStpragePlugin.m
//  Whitebox
//
//  Created by Olegs on 21/01/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import "SFTPStoragePlugin.h"

#define SFTP_SCRIPT_GET_STORAGE_PATH_F_CALL "window.SFTPStoragePlugin.getStoragePath(\"%@\");"
#define SFTP_SCRIPT_GET_WEB_PATH_F_CALL     "window.SFTPStoragePlugin.getWebPath(\"%@\", \"%@\", \"%@\", \"%@\");"

@implementation SFTPStoragePlugin

- (id) initPluginWithOptions:(NSDictionary *)options_ {
    if (self = [super initPluginWithOptions:options_]) {
        NSString *script_path = [self->options objectForKey:@"ScriptFilePath"];
        [self initScript:script_path];
    }
    
    return self;
}

- (BOOL) canHandleEvent:(int)event_id forSession:(Session *)session {
    
    if (event_id != RE_SCREEN_CAPTURE_CREATED &&
        event_id != RE_PLUGIN_SFTP_REUPLOAD) {
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
        NSString     *web_schema  = [self->options valueForKey:@"WebSchema"];
        NSString     *host        = [self->options valueForKey:@"Host"];
        NSString     *port        = [self->options valueForKey:@"Port"];
        NSString     *user        = [self->options valueForKey:@"User"];
        NSString     *web_port    = [self->options valueForKey:@"WebPort"];
        
        NSDictionary *session_context     = [session context];
        NSString     *input_file_path     = [session_context valueForKey:@SHRD_CTX_TMP_FILE_FULL_PATH];
        NSString     *yyyymmddhhiiss_name = [session_context valueForKey:@SHRD_CTX_YYYYMMDDHHIISS_FILE_NAME];
        Capture      *capture             = [session_context valueForKey:@SHRD_CTX_CAPTURE_MNGD_OBJ];
        
        if (yyyymmddhhiiss_name == NULL) {
            yyyymmddhhiiss_name = [Utils yyyymmddhhiiss];
            [session_context setValue:yyyymmddhhiiss_name forKey:@SHRD_CTX_YYYYMMDDHHIISS_FILE_NAME];
        }
        
        yyyymmddhhiiss_name = [NSString stringWithFormat:@"%@.%@", yyyymmddhhiiss_name, [WhiteBox valueForPathKey:@"Capture.Screen.FileExtension"]];
        
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        NSInteger num_port = [[f numberFromString:port] integerValue];
        f = nil;
        
        NMSSHSession *ssh_session = [NMSSHSession connectToHost:host port:num_port withUsername:user];
        
        if ([ssh_session isConnected]) {
        
            WebView *web_view = [WhiteBox valueForPathKey:@"Sandbox.Web.JS"];
            
            NSString *storage_path = [web_view stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@SFTP_SCRIPT_GET_STORAGE_PATH_F_CALL, yyyymmddhhiiss_name]];
            
            NSString *web_url = [web_view stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@SFTP_SCRIPT_GET_WEB_PATH_F_CALL, web_schema, host, web_port, yyyymmddhhiiss_name]];
            
            NSLog(@"Input file path: %@", input_file_path);
            NSLog(@"Storage path: %@", storage_path);
            NSLog(@"Web URL: %@", web_url);
            
            NSDictionary *capture_data_dict;
            
            [ssh_session authenticateByPublicKey:[self->options valueForKey:@"PublicKey"] privateKey:[self->options valueForKey:@"PrivateKey"] andPassword:nil];
            
            @try {
                
                if ([ssh_session.channel uploadFile:input_file_path to:storage_path]) {
                    
                    capture_data_dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                         web_url, @"meta",
                                         [self signature], @"provider",
                                         [NSNumber numberWithInt:CAPTURE_DATA_STATUS_OK ], @"status",
                                         nil
                                         ];
                } else {
                    
                    capture_data_dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                         @"", @"meta",
                                         [self signature], @"provider",
                                         [NSNumber numberWithInt:CAPTURE_DATA_STATUS_NOT_OK ], @"status",
                                         nil
                                         ];
                }
            }
            @catch (NSException *e) {
                NSLog(@"Exception thrown: %@", e);
            }
            
            [capture addCaptureDataFromDictionary:capture_data_dict];

            [ssh_session disconnect];

            fulfill(capture);
        } else {

            [ssh_session disconnect];

            reject(nil);
        }
    }];
}

- (id<ReactorPluginViewBuilder>) getViewBuilder {
    if (self->view_builder == NULL) {
        SFTPViewBuilder *vb = [[SFTPViewBuilder alloc] init];
        vb.hostname = [self->options objectForKey:@"Host"];
        self->view_builder = vb;
    }

    return self->view_builder;
}

@end
