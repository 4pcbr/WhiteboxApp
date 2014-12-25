//
//  Capture.m
//  Whitebox
//
//  Created by Olegs on 12/11/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import "Capture.h"
#import "CaptureData.h"


@implementation Capture

@dynamic created_at;
@dynamic type;
@dynamic capture_data;

- (void) addCaptureDataFromDictionary:(NSDictionary *)dictionary {
    NSManagedObjectContext *context = [self managedObjectContext];
    CaptureData *capture_data = [NSEntityDescription insertNewObjectForEntityForName:@"CaptureData" inManagedObjectContext:context];
    [capture_data setValuesForKeysWithDictionary:dictionary];
    return [self addCapture_dataObject:capture_data];
}

@end
