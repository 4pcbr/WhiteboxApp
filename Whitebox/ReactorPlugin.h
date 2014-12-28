//
//  ReactorPlugin.h
//  Whitebox
//
//  Created by Olegs on 12/11/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import <AppKit/NSMenuItem.h>
#import <Foundation/Foundation.h>
#import <PromiseKit/Promise.h>
#import "Capture.h"
#import "Processable.h"
#import "ReactorData.h"

@protocol ReactorPluginViewBuilder <NSObject>

@required

- (BOOL) hasMenuItem:(Capture *) capture;

- (NSMenuItem *) buildMenuItem:(Capture *) capture;

@end


@interface ReactorPlugin : NSObject<Processable> {
    BOOL                         enabled;
    NSDictionary                 * options;
    id<ReactorPluginViewBuilder> view_builder;
}

@property (nonatomic, strong, readonly) NSString *name;

- (id) initPluginWithOptions:(NSDictionary *)options;

- (BOOL) isEnabled;

- (void) enable;

- (void) disable;

- (PMKPromise *) run:(ReactorData *)event_data;

- (BOOL) canHandleEvent:(int)event_id withData:(ReactorData *)event_data;

- (NSString *) signature;

- (id<ReactorPluginViewBuilder>) getViewBuilder;

@end
