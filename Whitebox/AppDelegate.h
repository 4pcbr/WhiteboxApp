//
//  AppDelegate.h
//  Whitebox
//
//  Created by Olegs on 02/01/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import "CaptureMenuListViewController.h"
#import <Cocoa/Cocoa.h>
#import "NSFileHandle+StorePath.h"
#import "Reactor.h"
#import "ReactorEvents.h"
#import "ReactorDelegate.h"
#import "SessionManager.h"
#import "ScreenGrabber.h"
#import "SharedContextKeys.h"
#import <WebKit/WebView.h>


@interface AppDelegate : NSObject <NSApplicationDelegate, ReactorDelegate>

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

