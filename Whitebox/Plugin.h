//
//  Plugin.h
//  Whitebox
//
//  Created by Olegs on 12/11/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PromiseKit/Promise.h>
#import "Capture.h"


@interface Plugin : NSObject {
    BOOL enabled;
}

@property (nonatomic, strong, readonly) NSString *name;

- (id) initWithOptions:(NSDictionary *)options;

- (PMKPromise *) run:(Capture *)capture;

- (BOOL) canProceed:(Capture *)capture;

@end
