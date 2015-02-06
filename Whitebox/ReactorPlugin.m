//
//  ReactorPlugin.m
//  Whitebox
//
//  Created by Olegs on 12/11/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import "ReactorPlugin.h"

#define PLUGIN_OPTS_KEY_ENABLED "Enabled"

@implementation ReactorPlugin

- (id) initPluginWithOptions:(NSDictionary *)options_ {
    
    if ([options_ valueForKey:@PLUGIN_OPTS_KEY_ENABLED] != NULL) {
        self->enabled = (BOOL)[options_ valueForKey:@PLUGIN_OPTS_KEY_ENABLED];
    } else {
        self->enabled = YES;
    }
    
    if (self = [super init]) {
        self->options = options_;
    }
    
    return self;
}

- (BOOL) isEnabled {
    return self->enabled;
}

- (void) enable {
    self->enabled = YES;
}

- (void) disable {
    self->enabled = NO;
}

- (PMKPromise *) dispatch:(Session *)session {
    NSLog(@"You called a stub dispatch method.");
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (PMKPromise *) run:(Session *)session {
    return [self dispatch:session];
}

- (BOOL) canHandleEvent:(int)event_id forSession:(Session *)session {
    // Should be overriden in child classes
    return NO;
}

- (id<ReactorPluginViewBuilder>) getViewBuilder {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSString *) signature {
    return [self className];
}

- (void) initScript: (NSString *)script_path {
    if (!script_path) {
        @throw @"No script path settings provided. Failed to init the plugin.";
    }
    NSString *script_body = nil;
    if (![script_path hasPrefix:@"/"]) {
        NSString *script_name = [script_path stringByDeletingPathExtension];
        NSString *script_ext  = [script_path pathExtension];
        script_path = [[NSBundle mainBundle] pathForResource:script_name ofType:script_ext];
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


@end
