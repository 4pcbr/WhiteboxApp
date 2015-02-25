//
//  NSView+GetSubviewByIdentifier.m
//  Whitebox
//
//  Created by Olegs on 26/02/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import "NSView+GetSubviewByIdentifier.h"

@implementation NSView (GetSubviewByIdentifier)

- (NSView *) getSubviewByIdentifier:(NSString *)identifier {
    
    for (NSView *subview in self.subviews) {
        if ([subview.identifier isEqualToString:identifier]) {
            return subview;
        }
    }
    
    return nil;
}

- (NSView *) copySubviewWithIdentifier:(NSString *)identifier {
    NSView *subview = [self getSubviewByIdentifier:identifier];
    return (subview == nil) ? nil : [subview copyWithConstraints];
}

@end
