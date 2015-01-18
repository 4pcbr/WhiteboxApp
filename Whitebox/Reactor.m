//
//  Reactor.m
//  Whitebox
//
//  Created by Olegs on 27/11/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import "Reactor.h"

@implementation Reactor

- (id) init {
    if (self = [super init]) {
        self->plugins = [[NSHashTable alloc] init];
    }
    
    return self;
}

- (void) registerPlugin:(ReactorPlugin *)plugin {
    [self->plugins addObject:plugin];
}

- (void) releasePlugin:(ReactorPlugin *)plugin {
    [self->plugins removeObject:plugin];
}

- (PMKPromise *) emitEvent:(int)event_id session:(Session *)session {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        NSLog(@"Reactor event emited: id: %i, data: %@", event_id, session);
        
        NSMutableArray *responders = [[NSMutableArray alloc] init];
        
        NSLog(@"Looking for responders");
        
        NSLog(@"event_data: %@", [session valueForKey:@"context"]);
        
        for (ReactorPlugin *plugin in [self->plugins allObjects]) {
            
            if ([plugin canHandleEvent:event_id forSession:session]) {
                NSLog(@"Plugin %@ can handle the event", plugin.className);
                [responders addObject:plugin];
            }
        }
        
        NSLog(@"Done looking for responders");
        
        if ([responders count] == 0) {
            return fulfill(session);
        }
        
        PromiseQueue *pqueue = [[PromiseQueue alloc] initWithDeferreds:responders];
        
        [pqueue run:session].then(^(NSData *data) {
            fulfill(session);
        }).catch(^(NSError *error) {
            reject(error);
        }).finally(^{
        });
    }];
}

- (void) emitEvent:(int)event_id session:(Session *)session delegate:(id<ReactorDelegate>)delegate {
    
    [self emitEvent:event_id session:session].then(^(NSData * data) {
        [delegate reactorComplete:data];
    }).catch(^(NSError * error) {
        [delegate reactorFail:error];
    }).finally(^(void) {
        [delegate reactorFinally];
    });
}

@end
