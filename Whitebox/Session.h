//
//  Session.h
//  Whitebox
//
//  Created by Olegs on 14/01/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Session : NSObject {
    uint16 ssid;
    int    event_id;
}

@property (strong, nonatomic) NSMutableDictionary *context;

- (id) initWithSSID:(uint16)ssid;

- (uint16) ssid;

- (void) setEventID:(int)event_id;

- (int) eventID;

- (void) setContext:(NSMutableDictionary *)context;

- (NSMutableDictionary *) getContext;

- (void) expire;

@end
