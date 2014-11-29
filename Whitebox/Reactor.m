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
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        NSMutableArray *responders = [[NSMutableArray alloc] init];
        for (ReactorPlugin *plugin in self->plugins) {
            if ([plugin canHandleEvent:event_id]) {
                [responders addObject:plugin];
            }
        }
        
        if ([responders count] == 0) {
            return fulfill(event_data);
        }
        // TODO
    }];
}

- (void) emitEvent:(int)event_id data:(ReactorData *)event_data delegate:(id<ReactorDelegate>)delegate {
    // TODO
    [self emitEvent:event_id data:event_data].then(^(NSData * data) {
        [delegate reactorComplete:data];
    }).catch(^(NSError * error) {
        [delegate reactorFail:error];
    }).finally(^(void) {
        [delegate reactorFinally];
    });
}

@end
