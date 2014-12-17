//
//  PromiseQueue.m
//  ScreenCapture
//
//  Created by Olegs on 30/09/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import "PromiseQueue.h"

@implementation PromiseQueue {
    NSEnumerator *ptr;
}

- (id)initWithDeferreds:(NSArray *)processables_ {
    if (self = [super init]) {
        self->processables = [[NSMutableArray alloc] initWithArray:processables_];
        self->ptr = [self->processables objectEnumerator];
        NSLog(@"PromiseQueue has been inited with %lu elements", (unsigned long)[self->processables count]);
    }
    
    return self;
}

- (PMKPromise *)_next:(id)arg {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        id<Processable> obj;
        if (obj = [self->ptr nextObject]) {
            NSLog(@"About to call object proceed");
            [obj run:arg].then(^(NSData *data) {
                NSLog(@"Stepping over to to next procesible");
                [self _next:arg].then(^(NSData *data) {
                    fulfill(NULL);
                });
            });
        } else {
            NSLog(@"No further handlers found, exiting the queue loop");
            fulfill(NULL);
        }
    }];
}

- (PMKPromise *)proceed:(id)arg {
    return [self _next:arg];
}

@end
