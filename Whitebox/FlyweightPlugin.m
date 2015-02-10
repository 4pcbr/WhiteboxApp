//
//  FlyweightPlugin.m
//  Whitebox
//
//  Created by Olegs on 10/02/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import "FlyweightPlugin.h"

@implementation FlyweightPlugin

- (id) initWithBlock:(PMKPromise *(^)(Session *session))block_ eventID:(int)event_id_ {
    
    NSDictionary *plugin_options = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:YES], @PLUGIN_OPTS_KEY_ENABLED, nil];
    
    if (self = [super initPluginWithOptions:plugin_options]) {
        self.block = block_;
        self->event_id = event_id_;
    }
    
    return self;
}

- (BOOL) canHandleEvent:(int)event_id_ forSession:(Session *)session {
    return self->event_id == event_id_;
}

- (PMKPromise *) run:(Session *)session {
    return [self block](session);
}

- (id<ReactorPluginViewBuilder>) getViewBuilder {
    return nil;
}

@end
