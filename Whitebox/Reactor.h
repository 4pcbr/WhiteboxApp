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
#import "Session.h"
#import "SessionManager.h"

@interface Reactor : NSObject {
    NSHashTable *plugins;
}

- (void) registerPlugin:(ReactorPlugin *)plugin;

- (void) releasePlugin:(ReactorPlugin *)plugin;

- (PMKPromise *) emitEvent:(int)event_id session:(Session *)session;

- (void) emitEvent:(int)event_id session:(Session *)session delegate:(id<ReactorDelegate>)delegate;

@end
