//
//  SFTPViewBuilder.h
//  Whitebox
//
//  Created by Olegs on 21/01/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Capture.h"
#import "CaptureData.h"
#import "ReactorDelegate.h"
#import "ReactorPlugin.h"
#import "ReactorEvents.h"
#import "SessionManager.h"
#import "SharedContextKeys.h"

@interface SFTPViewBuilder : NSObject <ReactorPluginViewBuilder>

@property (strong, nonatomic) NSString *hostname;

@end
