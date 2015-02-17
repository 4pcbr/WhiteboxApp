//
//  Settings.h
//  Whitebox
//
//  Created by Olegs on 12/02/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define SETTINGS_TYPE_NUMBER    1
#define SETTINGS_TYPE_STRING    2
#define SETTINGS_TYPE_BOOL      3

enum SettingsAttrType {
    STRING,
    INTEGER,
    FLOAT,
    BOOLEAN
};

@interface Settings : NSManagedObject

@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * value;

@end
