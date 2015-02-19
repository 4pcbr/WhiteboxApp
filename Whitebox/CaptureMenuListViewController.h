//
//  CaptureMenuListViewController.h
//  Whitebox
//
//  Created by Olegs on 26/12/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Capture.h"
#import "CaptureData.h"
#import "ReactorPlugin.h"
#import "CaptureViewBuilder.h"

@interface CaptureMenuListViewController : NSViewController {
    IBOutlet NSMenuItem *anchor_menu_item;
}

@property (nonatomic, readwrite, retain) NSArray     *capture_list;
@property (nonatomic, weak, readwrite) NSHashTable   *plugins;

- (IBAction)captureListDidChange:(id)sender;

@end
