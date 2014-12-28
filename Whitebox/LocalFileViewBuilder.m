//
//  LocalFileViewBuilder.m
//  Whitebox
//
//  Created by Olegs on 28/12/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import "LocalFileViewBuilder.h"

@implementation LocalFileViewBuilder

- (BOOL) hasMenuItem:(Capture *)capture {
    return YES;
}

- (NSMenuItem *) buildMenuItem:(Capture *)capture {
    NSMenuItem *menu_item = [[NSMenuItem alloc] init];
    
    return menu_item;
}

@end
