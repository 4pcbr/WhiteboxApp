//
//  NSFileHandle+StorePath.m
//  Whitebox
//
//  Created by Olegs on 28/01/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import "NSFileHandle+StorePath.h"

@implementation NSFileHandle (StorePath)

static void *file_handlePropertyKey = &file_handlePropertyKey;

@dynamic file_path;

- (NSString *)file_path {
    return objc_getAssociatedObject(self, file_handlePropertyKey);
}

- (void) setFile_path:(NSString *)file_path_ {
    objc_setAssociatedObject(self, file_handlePropertyKey, file_path_, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
