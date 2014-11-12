//
//  JSPlugin.h
//  Whitebox
//
//  Created by Olegs on 12/11/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "Plugin.h"

@interface JSPlugin : Plugin

- (void)       undefinedJSMethodInvoked;
- (void)       done:(NSString *)data;
- (void)       fail:(NSString *)error;

+ (BOOL)       isSelectorExcludedFromWebScript:(SEL)aSelector;
+ (BOOL)       isKeyExcludedFromWebScript:(const char *)name;

@end
