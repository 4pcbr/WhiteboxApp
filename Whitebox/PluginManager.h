//
//  PluginManager.h
//  Whitebox
//
//  Created by Olegs on 19/12/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReactorPlugin.h"
#import "FlyweightPlugin.h"

@interface PluginManager : NSObject

@property (nonatomic, retain) NSMutableArray *plugins_;

+ (void) initPlugins:(NSDictionary *)settings;

+ (BOOL) isInited;

+ (NSMutableArray *) plugins;

+ (void) registerFlyweight:(PMKPromise *(^)(Session *session))block forEventID:(int) event_id;

@end
