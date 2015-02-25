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

+ (id)   valueForPathKey:(NSString *)path_key;

+ (BOOL) loadStateFromLocalFile:(NSString*) plist_file_name error:(NSError *__autoreleasing *)error;

+ (BOOL) saveStateToDB:(NSManagedObjectContext *)manged_object_context error:(NSError *__autoreleasing *)error;

+ (BOOL) loadStateFromDB:(NSManagedObjectContext *)manged_object_context error:(NSError *__autoreleasing *)error;

@end
