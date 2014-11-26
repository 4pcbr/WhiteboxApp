//
//  ScreenGrabberDelegate.h
//  Whitebox
//
//  Created by Olegs on 26/11/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ScreenGrabberDelegate

- (void) screenGrabberComplete: (NSFileHandle *)handle;
- (void) screenGrabberFail: (NSError *)error;
- (void) screenGrabberFinally;

@end
