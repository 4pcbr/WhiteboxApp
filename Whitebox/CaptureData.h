//
//  CaptureData.h
//  Whitebox
//
//  Created by Olegs on 12/11/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Capture;

@interface CaptureData : NSManagedObject

@property (nonatomic, retain) NSString * meta;
@property (nonatomic, retain) NSString * provider;
@property (nonatomic, retain) NSNumber * status;
@property (nonatomic, retain) Capture  * capture;

@end
