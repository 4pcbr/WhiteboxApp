//
//  CaptureViewBuilder.h
//  Whitebox
//
//  Created by Olegs on 26/12/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/NSMenu.h>
#import <AppKit/NSMenuItem.h>
#import "Capture.h"
#import "CaptureData.h"
#import "WhiteBox.h"
#import "ReactorPlugin.h"
#import "PluginManager.h"

@interface CaptureViewBuilder : NSObject

+ (NSMenuItem *) buildMenuItem:(Capture *)capture;

@end
