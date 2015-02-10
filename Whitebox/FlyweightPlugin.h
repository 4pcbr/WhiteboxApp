//
//  FlyweightPlugin.h
//  Whitebox
//
//  Created by Olegs on 10/02/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import "ReactorPlugin.h"
#import <PromiseKit/Promise.h>
#import "Session.h"

@interface FlyweightPlugin : ReactorPlugin {
    int event_id;
}

@property (nonatomic, copy) PMKPromise *(^block)(Session *session);

- (id) initWithBlock:(PMKPromise *(^)(Session *session))block eventID:(int)event_id;

@end
