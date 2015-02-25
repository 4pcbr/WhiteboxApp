//
//  NSView+CopyWithConstraints.m
//  Whitebox
//
//  Created by Olegs on 26/02/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import "NSView+CopyWithConstraints.h"

@implementation NSView (CopyWithConstraints)

- (NSView *) copyWithConstraints {
    
    // See http://stackoverflow.com/questions/3107429/copy-nsview-in-cocoa-objective-c
    NSData *constraints  = [NSKeyedArchiver archivedDataWithRootObject:self];
    NSView *subview_copy = [NSKeyedUnarchiver unarchiveObjectWithData:constraints];
    
    return subview_copy;
}

@end
