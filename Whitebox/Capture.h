//
//  Capture.h
//  Whitebox
//
//  Created by Olegs on 12/11/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CaptureData;

@interface Capture : NSManagedObject

@property (nonatomic, retain) NSDate    * created_at;
@property (nonatomic, retain) NSNumber  * type;
@property (nonatomic, retain) NSSet     * capture_data;
@end

@interface Capture (CoreDataGeneratedAccessors)

- (void)addCapture_dataObject:(CaptureData *)value;
- (void)removeCapture_dataObject:(CaptureData *)value;
- (void)addCapture_data:(NSSet *)values;
- (void)removeCapture_data:(NSSet *)values;

@end
