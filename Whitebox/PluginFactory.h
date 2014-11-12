//
//  PluginFactory.h
//  Whitebox
//
//  Created by Olegs on 12/11/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import "Plugin.h"

@interface PluginFactory : Plugin

+ (NSArray *) initPluginsForBundle:(NSBundle *)bundle inDirectory:(NSString *)directory ofType:(NSString *)type withOptions:(NSDictionary *)options;

@end
