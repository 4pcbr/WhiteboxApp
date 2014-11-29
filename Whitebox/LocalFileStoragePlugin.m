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

- (BOOL) canProceed:(Capture *)capture {
    return YES; //([capture class] == [ImageFileCapture class]);
}

@end
