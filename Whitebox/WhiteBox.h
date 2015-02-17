//
//  WhiteBox.h
//  Whitebox
//
//  Created by Olegs on 25/12/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import <CoreData/NSManagedObjectContext.h>
#import <Foundation/Foundation.h>
#import "Settings.h"

@interface WhiteBox : NSObject

+ (void) setOptions:(NSDictionary *)options;

+ (void) setValue:(id)value ForPathKey:(NSString *)path_key;

+ (id) valueForPathKey:(NSString *)path_key;

+ (void) saveState:(NSManagedObjectContext *)manged_object_context;

+ (void) reloadState:(NSManagedObjectContext *)manged_object_context;

@end
