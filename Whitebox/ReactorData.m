//
//  ReactorData.m
//  Whitebox
//
//  Created by Olegs on 27/11/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import "ReactorData.h"

@implementation ReactorData

@synthesize data = data;

- (id) initWithData:(id)_data {
    if (self = [super init]) {
        self.data = _data;
    }
    
    return self;
}

//- (id) valueForKey:(NSString *)key {
//    return [self.data objectForKey:key];
//}
//
//- (void) setValue:(id)value forKey:(NSString *)key {
//    [self.data setObject:value forKey:key];
//}

@end
