//
//  Session.m
//  Whitebox
//
//  Created by Olegs on 14/01/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import "Session.h"

@implementation Session

- (id) initWithSSID:(uint16)ssid_ {
    if (self = [super init]) {
        self->ssid = ssid_;
        self->_context = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (uint16) ssid {
    return self->ssid;
}

- (void) setContext:(NSMutableDictionary *)context {
    self->_context = context;
}

- (NSMutableDictionary *) getContext {
    return self->_context;
}

- (void) expire {
    [self->_context removeAllObjects];
}

- (void) setEventID:(int)event_id_ {
    self->event_id = event_id_;
}

- (int) eventID {
    return self->event_id;
}

@end
