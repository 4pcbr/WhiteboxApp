//
//  CaptureMenuListViewController.m
//  Whitebox
//
//  Created by Olegs on 26/12/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import "CaptureMenuListViewController.h"

@interface CaptureMenuListViewController ()

@end

@implementation CaptureMenuListViewController {
    NSMutableArray *menu_items;
}

@synthesize plugins      = plugins_;
@synthesize capture_list = capture_list_;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)captureListDidChange:(id)sender {

    if (self.capture_list == NULL) {
        NSLog(@"No capture list provided, exiting now.");
        return;
    }
    
    if (self.plugins == NULL) {
        NSLog(@"No plugins provided, exiting now.");
        return;
    }
    
    [self releaseMenuItems];
    [self buildMenuItems];
    [self updateAnchorMenuItem];
}

- (void) releaseMenuItems {
    
    if (self->menu_items == NULL) {
        return;
    }
    
    NSMenu *menu = [anchor_menu_item menu];
    
    for (NSMenuItem *menu_item in self->menu_items) {
        [menu removeItem:menu_item];
    }
    
    self->menu_items = [[NSMutableArray alloc] init];
}

- (void) buildMenuItems {
    NSMenu *menu = [anchor_menu_item menu];
    NSInteger anchor_index = [menu indexOfItem:anchor_menu_item];
    
    if (self->menu_items == NULL) {
        self->menu_items = [[NSMutableArray alloc] init];
    }
    
    for (Capture *capture in self.capture_list) {
        NSMenuItem *menu_item = [CaptureViewBuilder buildMenuItem:capture];
        [self->menu_items addObject:menu_item];
        [menu insertItem:menu_item atIndex:(++anchor_index)];
    }
}

- (void) updateAnchorMenuItem {
    if ([self.capture_list count] > 0) {
        anchor_menu_item.title = NSLocalizedString(@"CAPTURE_RECENTS", nil);
    } else {
        anchor_menu_item.title = NSLocalizedString(@"CAPTURE_NO_RECENTS", nil);
    }
}

@end
