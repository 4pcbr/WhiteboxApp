//
//  RESTViewBuilder.h
//  Whitebox
//
//  Created by Olegs on 18/01/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import <AppKit/NSAlert.h>
#import <Foundation/Foundation.h>
#import "ReactorPlugin.h"
#import "CaptureData.h"

@interface RESTViewBuilder : NSObject <ReactorPluginViewBuilder>

@property (strong, nonatomic) NSString *hostname;

@end
