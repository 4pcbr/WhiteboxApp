//
//  PluginFactory.m
//  Whitebox
//
//  Created by Olegs on 12/11/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import "PluginFactory.h"
#import "JSPlugin.h"

static NSDictionary *PLUGIN_TYPES = nil;

@implementation PluginFactory

+ (void) initialize {
    if (!PLUGIN_TYPES) {
        PLUGIN_TYPES = [[NSDictionary alloc] initWithObjectsAndKeys:@"JSPlugin",@"js", nil];
    }
}

+ (NSArray *) initPluginsForBundle:(NSBundle *)bundle inDirectory:(NSString *)directory ofType:(NSString *)type withOptions:(NSDictionary *)options {
    
    NSString *pluginKlassName = [PLUGIN_TYPES valueForKey:type];
    
    if (!pluginKlassName) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:@"Unable to init a plugin of type %@", type]
                                     userInfo:nil];
    }
    
    Class           pluginKlass = NSClassFromString(pluginKlassName);

    NSMutableArray *plugins = [[NSMutableArray alloc] init];

    NSArray        *sourceFiles = [bundle pathsForResourcesOfType:[NSString stringWithFormat:@".%@", type] inDirectory:directory];

    for (NSString  *sourceFile in sourceFiles) {

        NSString   *sourceCode = [NSString stringWithContentsOfFile:sourceFile encoding:NSUTF8StringEncoding error:nil];
        
        Plugin     *plugin = [[pluginKlass alloc] initWithSourceCode:sourceCode andOptions:options];

        [plugins addObject:plugin];

    }

    return plugins;
}

@end
