//
//  Reactor.h
//  Whitebox
//
//  Created by Olegs on 27/11/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PromiseKit/Promise.h>
#import "ReactorPlugin.h"
#import "ReactorData.h"
#import "ReactorDelegate.h"
#import "PromiseQueue.h"

@interface Reactor : NSObject {
    NSMutableArray *plugins;
    NSMutableArray *event_data_arr;
}

- (void) registerPlugin:(ReactorPlugin *)plugin;

- (void) releasePlugin:(ReactorPlugin *)plugin;

- (PMKPromise *) emitEvent:(int)event_id data:(ReactorData *)event_data;

- (void) emitEvent:(int)event_id data:(ReactorData *)event_data delegate:(id<ReactorDelegate>)delegate;

@end
