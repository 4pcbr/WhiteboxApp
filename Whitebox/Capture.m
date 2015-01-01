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

- (CaptureData *)getCaptureDataInstanceWithPredicate:(NSPredicate *)original_predicate {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CaptureData"];
    NSPredicate *id_match_predicate = [NSPredicate predicateWithFormat:@"self.capture=%@", self];
    NSArray *predicates = [NSArray arrayWithObjects: original_predicate, id_match_predicate, nil];
    [request setPredicate:[NSCompoundPredicate andPredicateWithSubpredicates: predicates]];
    NSError *error = nil;
    
    return [[[self managedObjectContext] executeFetchRequest:request error:&error] firstObject];
}

@end
