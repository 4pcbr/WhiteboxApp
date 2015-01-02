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
        self->plugins = [[NSMutableArray alloc] init];
        self->event_data_arr = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void) registerPlugin:(ReactorPlugin *)plugin {
    [self->plugins addObject:plugin];
}

- (void) releasePlugin:(ReactorPlugin *)plugin {
    [self->plugins removeObject:plugin];
}

- (PMKPromise *) emitEvent:(int)event_id data:(ReactorData *)event_data {
    [self->event_data_arr addObject:event_data];
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        NSLog(@"Reactor event emited: id: %i, data: %@", event_id, event_data);
        
        NSMutableArray *responders = [[NSMutableArray alloc] init];
        
        NSLog(@"Looking for responders");
        
        for (ReactorPlugin *plugin in self->plugins) {
            
            if ([plugin canHandleEvent:event_id withData:event_data]) {
                NSLog(@"Plugin %@ can handle the event", plugin.className);
                [responders addObject:plugin];
            }
        }
        
        NSLog(@"Done looking for responders");
        
        if ([responders count] == 0) {
            return fulfill(event_data);
        }
        
        PromiseQueue *pqueue = [[PromiseQueue alloc] initWithDeferreds:responders];
        [pqueue run:event_data].then(^(NSData *data) {
            fulfill(data);
        }).catch(^(NSError *error) {
            reject(error);
        }).finally(^{
            [self->event_data_arr removeObject:event_data];
        });
    }];
}

- (void) emitEvent:(int)event_id data:(ReactorData *)event_data delegate:(id<ReactorDelegate>)delegate {
    
    [self emitEvent:event_id data:event_data].then(^(NSData * data) {
        [delegate reactorComplete:data];
    }).catch(^(NSError * error) {
        [delegate reactorFail:error];
    }).finally(^(void) {
        [delegate reactorFinally];
    });
}

@end
