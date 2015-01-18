//
//  ASIFormDataRequestWithSSID.m
//  Whitebox
//
//  Created by Olegs on 18/01/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import "ASIFormDataRequestWithSSID.h"

@implementation ASIFormDataRequestWithSSID

- (uint16) getSSID {
    return self->ssid;
}

- (void) setSSID:(uint16)ssid_ {
    self->ssid = ssid_;
}

- (void) setFulfiller:(PMKPromiseFulfiller) fulfill_ {
    self->fulfill = fulfill_;
}
- (void) setRejecter:(PMKPromiseRejecter) reject_ {
    self->reject = reject_;
}

- (PMKPromiseFulfiller) getFulfiller {
    return self->fulfill;
}

- (PMKPromiseRejecter)  getRejecter {
    return self->reject;
}

@end
