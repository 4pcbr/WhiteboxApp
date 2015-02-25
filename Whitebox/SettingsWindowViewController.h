//
//  SettingsWindowViewController.h
//  Whitebox
//
//  Created by Olegs on 19/02/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSView+CopyWithConstraints.h"
#import "NSView+GetSubviewByIdentifier.h"
#import "PluginManager.h"
#import "ReactorPlugin.h"
#import "WhiteBox.h"

@interface SettingsWindowViewController : NSViewController<NSTableViewDataSource, NSTableViewDelegate>;

- (void) buildPluginSettingsView;

@property (nonatomic, retain) NSMutableArray *plugins;

@end
