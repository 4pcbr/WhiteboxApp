//
//  RESTStoragePlugin.m
//  Whitebox
//
//  Created by Olegs on 02/01/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import "RESTStoragePlugin.h"

#define REST_SCRIPT_PARSE_RESPONSE_F_CALL "window.RESTStoragePlugin.parseResponse(\"%@\");"

@implementation RESTStoragePlugin

- (id) initPluginWithOptions:(NSDictionary *)options_ {
    if (self = [super initPluginWithOptions:options_]) {
        NSString *script_path = [self->options objectForKey:@"ScriptFilePath"];
        [self initScript:script_path];
    }
    
    return self;
}

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
    
    uint16        ssid                = [session ssid];
    NSDictionary *session_context     = [session context];
    NSFileHandle *input_file          = [session_context valueForKey:@SHRD_CTX_TMP_FILE_HANDLE];
    NSString     *yyyymmddhhiiss_name = [session_context valueForKey:@SHRD_CTX_YYYYMMDDHHIISS_FILE_NAME];
    NSString     *file_ext            = [WhiteBox valueForPathKey:@"Capture.Screen.FileExtension"];
    NSString     *content_type        = [WhiteBox valueForPathKey:@"Capture.Screen.ContentType"];
    
    NSString     *scheme              = [self->options objectForKey:@"Scheme"];
    NSString     *host                = [self->options objectForKey:@"Host"];
    NSString     *path                = [self->options objectForKey:@"Path"];
    NSString     *param_name          = [self->options objectForKey:@"ParamName"];
    
    NSString     *file_name           = [NSString stringWithFormat:@"%@.%@", yyyymmddhhiiss_name, file_ext];
    NSURL        *url                 = [[NSURL alloc] initWithScheme:scheme host:host path:path];
    NSData       *file_contents       = [input_file readDataToEndOfFile];
    
    [input_file seekToFileOffset:0];
    
    ASIFormDataRequestWithSSID *request = [ASIFormDataRequestWithSSID requestWithURL:url];
    
    [request setData:file_contents withFileName:file_name andContentType:content_type forKey:param_name];
    
    [request setDelegate:self];
    
    [request setSSID:ssid];
    
    PMKPromise *promise = [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        [request setFulfiller:fulfill];
        [request setRejecter:reject];
        [request startAsynchronous];
    }];
    
    return promise;
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    
    NSLog(@"I'm in!");
    uint16 ssid = [(ASIFormDataRequestWithSSID *)request getSSID];
    NSLog(@"SSID: %i", ssid);
    Session *session = [SessionManager retrieveSessionBySSID:ssid];
    NSLog(@"Session: %@", session);
    
    NSString *response_string = [request responseString];
    int response_status_code  = [request responseStatusCode];
    
    NSLog(@"Response status code: %i", response_status_code);
    
    WebView *web_view = [WhiteBox valueForPathKey:@"Sandbox.Web.JS"];

    NSString *parse_result = [web_view stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@REST_SCRIPT_PARSE_RESPONSE_F_CALL, response_string]];

    NSLog(@"Parse result: %@", parse_result);
    
    NSDictionary *session_context     = [session context];
    Capture      *capture             = [session_context valueForKey:@SHRD_CTX_CAPTURE_MNGD_OBJ];
    
    NSLog(@"Capture: %@", capture);
    
    NSDictionary *capture_data_dict;
    
    NSString *scheme = [self->options objectForKey:@"Scheme"];
    NSString *host   = [self->options objectForKey:@"Host"];
    
    if ([parse_result length] > 0) {
        NSURL *result_URL = [[NSURL alloc] initWithScheme:scheme host:host path:parse_result];

        NSLog(@"Result URL: %@", [result_URL absoluteString]);

        capture_data_dict = [[NSDictionary alloc] initWithObjectsAndKeys:
           [result_URL absoluteString], @"meta",
           [self signature], @"provider",
           [NSNumber numberWithInt:CAPTURE_DATA_STATUS_OK ], @"status",
           nil
        ];
    } else {
        NSLog(@"Oh, shit!");

        capture_data_dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                           @"Got an empty parse result.", @"meta",
                                           [self signature], @"provider",
                                           [NSNumber numberWithInt:CAPTURE_DATA_STATUS_NOT_OK ], @"status",
                                           nil
                                           ];
        @throw @"WTF!";
    }
    
    [capture addCaptureDataFromDictionary:capture_data_dict];
    
    PMKPromiseFulfiller fulfill = [(ASIFormDataRequestWithSSID *)request getFulfiller];
    
    fulfill(capture);
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSLog(@"Screw you guys! I'm going home.");
    PMKPromiseRejecter reject = [(ASIFormDataRequestWithSSID *)request getRejecter];
    reject(request.error);
}

- (void) initScript: (NSString *)script_path {
    if (!script_path) {
        @throw @"No script path settings provided. Failed to init the plugin.";
    }
    NSString *script_body = nil;
    if (![script_path hasPrefix:@"/"]) {
        // Not an absolute path, we should consider it as a local resource file
        script_path = [[NSBundle mainBundle] pathForResource:@"RESTStoragePlugin" ofType:@"js"];
    }
    NSError *error = nil;
    script_body = [NSString stringWithContentsOfFile:script_path encoding:NSUTF8StringEncoding error:&error];
    
    NSLog(@"Script body: %@", script_body);
    
    if (error != nil) {
        NSLog(@"Error while reading the script file: %@", error);
        @throw @"Error while reading the script file. Failed to init the plugin.";
    }
    
    WebView *web_view = [WhiteBox valueForPathKey:@"Sandbox.Web.JS"];
    
    NSString *js_eval_status = [web_view stringByEvaluatingJavaScriptFromString:script_body];
    if (![js_eval_status isEqualToString:@"1"]) {
        NSLog(@"JS eval status: %@", js_eval_status);
        @throw @"Non-zero JS eval exit code. Failed to init the plugin.";
    }
}

- (id<ReactorPluginViewBuilder>) getViewBuilder {
    if (self->view_builder == NULL) {
        RESTViewBuilder *vb = [[RESTViewBuilder alloc] init];
        vb.hostname = [self->options objectForKey:@"Host"];
        self->view_builder = vb;
    }
    return self->view_builder;
}

@end
