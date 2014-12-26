//
//  WhiteBox.h
//  Whitebox
//
//  Created by Olegs on 25/12/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WhiteBox : NSObject

+ (void) setOptions:(NSDictionary *)options;

+ (void) setValue:(id)value ForPathKey:(NSString *)path_key;

+ (id) valueForPathKey:(NSString *)path_key;

@end
