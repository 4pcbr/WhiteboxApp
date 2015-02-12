//
//  SessionManager.m
//  Whitebox
//
//  Created by Olegs on 14/01/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import "SessionManager.h"


@implementation SessionManager

- (id) init {
    if (self = [super init]) {
        self->_sessions = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

static SessionManager *_instance;
+ (SessionManager *) instance {
    @synchronized(self) {
        if (_instance == nil) {
            _instance = [[SessionManager alloc] init];
        }
        
        return _instance;
    }
}

+ (uint16) generateSSID {
    return arc4random_uniform(65535);
}

+ (Session *) createSession {
    @synchronized(self) {
        uint16 ssid = 0;
        while (1) {
            ssid = [self generateSSID];
            if ([[self instance]->_sessions objectForKey:[NSString stringWithFormat:@"%i", ssid]] == nil) {
                break;
            }
        }
        Session *session = [[Session alloc] initWithSSID:ssid];
        [[self instance]->_sessions setObject:session forKey:[NSString stringWithFormat:@"%i", ssid]];
        return session;
    }
}

+ (void) expireSessionBySSID:(uint16)ssid {
    Session *session = [[self instance]->_sessions objectForKey:[NSString stringWithFormat:@"%i", ssid]];
    NSLog(@"Expiration: %@", session);
    [[self instance]->_sessions removeObjectForKey:[NSString stringWithFormat:@"%i", ssid]];
}

+ (Session *) retrieveSessionBySSID:(uint16)ssid {
    @synchronized(self) {
        NSString *key = [NSString stringWithFormat:@"%i", ssid];
        Session *session = [[self instance]->_sessions objectForKey:key];
        return session;
    }
}

@end
