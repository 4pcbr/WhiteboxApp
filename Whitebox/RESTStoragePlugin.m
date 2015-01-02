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
        NSString *script_path = [self->options valueForKey:@"ScriptFilePath"];
        [self initScript:script_path];
    }
    
    return self;
}

- (BOOL) canHandleEvent:(int)event_id withData:(ReactorData *)event_data {
    
    if (event_id != RE_SCREEN_CAPTURE_CREATED) {
        NSLog(@"Don't know how to handle an event with this ID");
        return NO;
    };
    
    Capture *capture = [event_data valueForKey:@SHRD_CTX_CAPTURE_MNGD_OBJ];
    
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

- (PMKPromise *) run:(ReactorData *)event_data {
    
    Capture      *capture             = [event_data valueForKey:@SHRD_CTX_CAPTURE_MNGD_OBJ];
    NSFileHandle *input_file          = [event_data valueForKey:@SHRD_CTX_TMP_FILE_HANDLE];
    NSString     *yyyymmddhhiiss_name = [event_data valueForKey:@SHRD_CTX_YYYYMMDDHHIISS_FILE_NAME];
    NSString     *file_ext            = [WhiteBox valueForPathKey:@"Capture.Screen.FileExtension"];
    NSString     *content_type        = [WhiteBox valueForPathKey:@"Capture.Screen.ContentType"];
    
    NSString     *scheme              = [self->options valueForKey:@"Scheme"];
    NSString     *host                = [self->options valueForKey:@"Host"];
    NSString     *path                = [self->options valueForKey:@"Path"];
    NSString     *param_name          = [self->options valueForKey:@"ParamName"];
    
    if (yyyymmddhhiiss_name == NULL) {
        yyyymmddhhiiss_name = [Utils yyyymmddhhiiss];
        [event_data setValue:yyyymmddhhiiss_name forKey:@SHRD_CTX_YYYYMMDDHHIISS_FILE_NAME];
    }
    
    NSString     *file_name           = [NSString stringWithFormat:@"%@.%@", yyyymmddhhiiss_name, file_ext];
    NSURL        *url                 = [[NSURL alloc] initWithScheme:scheme host:host path:path];

    [input_file seekToFileOffset:0];
    
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        NSData             *file_contents = [input_file readDataToEndOfFile];
        ASIFormDataRequest *request       = [ASIFormDataRequest requestWithURL:url];
        
        NSLog(@"REST URL: %@", url);
        
        [request setData:file_contents withFileName:file_name andContentType:content_type forKey:param_name];
        
        [request setCompletionBlock:^{
            NSString *response_body = [request responseString];
            int       response_code = [request responseStatusCode];
            
            NSLog(@"Response code: %d", response_code);
            
            NSLog(@"response_body: %@", response_body);
            
            NSLog(@"String to be evaluated: %@", [NSString stringWithFormat:@REST_SCRIPT_PARSE_RESPONSE_F_CALL, response_body]);
            
            WebView *web_view = [WhiteBox valueForPathKey:@"Sandbox.Web.JS"];
            
            NSString *result = [web_view stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@REST_SCRIPT_PARSE_RESPONSE_F_CALL, response_body]];
            
            NSLog(@"Response body: %@", response_body);
            
            NSString *check_func_exists = [web_view stringByEvaluatingJavaScriptFromString:@"typeof(window.RESTStoragePlugin.parseResponse)"];
            
            NSLog(@"Func exists check: %@", check_func_exists);
            
            NSLog(@"Response parse result: %@", result);
            
            NSDictionary *capture_data_dict;
            
            NSLog(@"Plugins: %@", [PluginManager plugins]);
            
            if ([result length] > 0) {
                
                NSURL *result_URL = [[NSURL alloc] initWithScheme:scheme host:host path:result];
                
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
            
            fulfill(capture);
        }];
        
        [request setFailedBlock:^{
            NSDictionary *capture_data_dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                               request.error.description, @"meta",
                                               [self signature], @"provider",
                                               [NSNumber numberWithInt:CAPTURE_DATA_STATUS_NOT_OK ], @"status",
                                               nil
                                               ];
            
            [capture addCaptureDataFromDictionary:capture_data_dict];

            reject(request.error);
        }];
        
        [request startAsynchronous];
        [input_file seekToFileOffset:0];
    }];
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
    // TODO
    return nil;
}

@end
