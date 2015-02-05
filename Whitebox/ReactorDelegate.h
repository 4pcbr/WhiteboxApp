//
//  ReactorDelegate.h
//  Whitebox
//
//  Created by Olegs on 27/11/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PromiseKit/Promise.h>
#import "Session.h"

@protocol ReactorDelegate

- (void) reactorComplete:(NSData *)data;

- (void) reactorFail:(NSError *)error;

- (void) reactorFinally;

- (PMKPromise *) emitEvent:(int)event_id session:(Session *)session;

- (void) emitEvent:(int)event_id session:(Session *)session delegate:(id<ReactorDelegate>)delegate;

@end
