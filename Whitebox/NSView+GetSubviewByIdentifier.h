//
//  NSView+GetSubviewByIdentifier.h
//  Whitebox
//
//  Created by Olegs on 26/02/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSView+CopyWithConstraints.h"

@interface NSView (GetSubviewByIdentifier)

- (NSView *) getSubviewByIdentifier:(NSString *) identifier;

- (NSView *) copySubviewWithIdentifier:(NSString *) identifier;

@end
