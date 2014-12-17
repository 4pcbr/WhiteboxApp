//
//  ReactorPlugin.h
//  Whitebox
//
//  Created by Olegs on 12/11/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <PromiseKit/Promise.h>
#import "Capture.h"
#import "Processable.h"
#import "ReactorData.h"


@interface ReactorPlugin : NSObject<Processable> {
    BOOL           enabled;
    NSDictionary * options;
}

@property (nonatomic, strong, readonly) NSString *name;

- (id) initWithOptions:(NSDictionary *)options;

- (PMKPromise *) run:(ReactorData *)event_data;

- (BOOL) canHandleEvent:(int)event_id;

- (BOOL) canProceed:(ReactorData *)event_data;

@end
