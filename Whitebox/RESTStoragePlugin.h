//
//  RESTStoragePlugin.h
//  Whitebox
//
//  Created by Olegs on 02/01/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//


#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import <ASIHTTPRequest/ASIFormDataRequest.h>
#import "ASIFormDataRequestWithSSID.h"
#import "Capture.h"
#import "CaptureData.h"
#import "PluginManager.h"
#import "ReactorPlugin.h"
#import "ReactorEvents.h"
#import "ReactorData.h"
#import "RESTViewBuilder.h"
#import "SharedContextKeys.h"
#import "SessionManager.h"
#import "Utils.h"
#import "WhiteBox.h"
#import <WebKit/WebView.h>

@interface RESTStoragePlugin : ReactorPlugin

- (void)requestFinished:(ASIHTTPRequest *)request;

- (void)requestFailed:(ASIHTTPRequest *)request;

@end
