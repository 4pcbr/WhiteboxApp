//
//  PluginManager.m
//  Whitebox
//
//  Created by Olegs on 19/12/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import "PluginManager.h"

@implementation PluginManager

static NSMutableArray *plugins_ = nil;

+ (BOOL) isInited {
    return plugins_ == nil;
}

+ (void) initPlugins:(NSDictionary *)settings {
    plugins_ = [[NSMutableArray alloc] init];
    
    for (NSString *plugin_name in settings) {
        NSDictionary *plugin_options = (NSDictionary*)[settings valueForKey:plugin_name];
        Class klass = NSClassFromString(plugin_name);
        ReactorPlugin *plugin = [[klass alloc] initPluginWithOptions:plugin_options];
        [plugins_ addObject:plugin];
    }
}

+ (NSArray *) plugins {
    return plugins_;
}

@end
