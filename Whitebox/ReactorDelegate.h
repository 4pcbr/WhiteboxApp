//
//  ReactorDelegate.h
//  Whitebox
//
//  Created by Olegs on 27/11/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ReactorDelegate

- (void) reactorComplete:(NSData *)data;

- (void) reactorFail:(NSError *)error;

- (void) reactorFinally;

@end
