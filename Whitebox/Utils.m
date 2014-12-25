//
//  Utils.m
//  Whitebox
//
//  Created by Olegs on 25/12/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (NSString *)yyyymmddhhiiss {
    NSDateFormatter *date_formatter=[[NSDateFormatter alloc] init];
    [date_formatter setDateFormat:@"yyyyMMddHHmmss"];
    
    return [date_formatter stringFromDate:[NSDate date]];
}

@end
