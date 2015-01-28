//
//  SFTPViewBuilder.h
//  Whitebox
//
//  Created by Olegs on 21/01/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReactorPlugin.h"
#import "Capture.h"
#import "CaptureData.h"

@interface SFTPViewBuilder : NSObject <ReactorPluginViewBuilder>

@property (strong, nonatomic) NSString *hostname;

@end
