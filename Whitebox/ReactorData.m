//
//  ReactorData.m
//  Whitebox
//
//  Created by Olegs on 27/11/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import "ReactorData.h"

@implementation ReactorData

- (id) initWithData:(id)data_ {
    if (self = [super init]) {
        self.data = data_;
    }
    
    return self;
}

- (id) valueForKey:(NSString *)key {
    return [self.data valueForKey:key];
}

- (void) setValue:(id)value forKey:(NSString *)key {
    [self.data setValue:value forKey:key];
}

@end
