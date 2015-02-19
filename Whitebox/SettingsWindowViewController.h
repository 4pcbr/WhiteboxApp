//
//  SettingsWindowViewController.h
//  Whitebox
//
//  Created by Olegs on 19/02/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ReactorPlugin.h"
#import "WhiteBox.h"

@interface SettingsWindowViewController : NSViewController

@property (nonatomic, weak, readwrite) NSHashTable *plugins;

- (void) buildPluginSettingsView;

@end
