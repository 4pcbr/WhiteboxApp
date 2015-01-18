//
//  ASIFormDataRequestWithSSID.h
//  Whitebox
//
//  Created by Olegs on 18/01/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import "ASIFormDataRequest.h"
#import <PromiseKit/PromiseKit.h>

@interface ASIFormDataRequestWithSSID : ASIFormDataRequest {
    uint16 ssid;
    PMKPromiseFulfiller fulfill;
    PMKPromiseRejecter  reject;
}

- (void)   setSSID:(uint16)ssid;
- (uint16) getSSID;

- (void) setFulfiller:(PMKPromiseFulfiller) fulfill;
- (void) setRejecter:(PMKPromiseRejecter) reject;

- (PMKPromiseFulfiller) getFulfiller;
- (PMKPromiseRejecter)  getRejecter;

@end
