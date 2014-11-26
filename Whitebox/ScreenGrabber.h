//
//  ScreenGrabber.h
//  Whitebox
//
//  Created by Olegs on 23/11/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import <PromiseKit/Promise.h>
#import <PromiseKit/NSTask+PromiseKit.h>
#import "Plugin.h"
#import "ScreenGrabberDelegate.h"

@interface ScreenGrabber : Plugin

+ (PMKPromise *) capture:(NSDictionary *)options;
+ (void) capture:(NSDictionary *)options delegate:(id<ScreenGrabberDelegate>)delegate;

@end
