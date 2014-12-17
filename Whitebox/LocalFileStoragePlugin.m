//
//  LocalFileStorage.m
//  Whitebox
//
//  Created by Olegs on 23/11/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import "LocalFileStoragePlugin.h"

@implementation LocalFileStoragePlugin

- (BOOL) canHandleEvent:(int)event_id {
    return event_id == RE_SCREEN_CAPTURE_CREATED;
}

- (BOOL) canProceed:(ReactorData *)event_data {
    
    Capture *capture = [event_data valueForKey:@SHRD_CTX_CAPTURE_MNGD_OBJ];
    
    if (!capture) {
        return NO;
    }
    
    return capture.type.intValue == CAPTURE_TYPE_SCREEN_IMG;
}

@end
