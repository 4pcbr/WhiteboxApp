//
//  ReactorPlugin.m
//  Whitebox
//
//  Created by Olegs on 12/11/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import "ReactorPlugin.h"
#import "Whitebox-Swift.h"

@implementation ReactorPlugin

- (id) initPluginWithOptions:(NSDictionary *)options_ {
    if (self = [super init]) {
        self->options = options_;
    }
    
    return self;
}

- (PMKPromise *) run:(ReactorData *)event_data {
    NSLog(@"You ran into a stub run method.");
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (BOOL) canHandleEvent:(int)event_id withData:(ReactorData *)event_data {
    // Should be overriden in child classes
    return NO;
}

- (id<ReactorPluginViewBuilder>) getViewBuilder {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (NSString *) signature {
    return [self className];
}

@end
