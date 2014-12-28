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
    menu_item.title = NSLocalizedString(@"REVEAL_IN_FINDER", nil);
    menu_item.action = @selector(menuItemDidClick:);
    menu_item.target = self;
    return menu_item;
}

- (void)menuItemDidClick:(id)sender {
    
}

@end
