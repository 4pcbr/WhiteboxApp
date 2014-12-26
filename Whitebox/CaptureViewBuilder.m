//
//  CaptureViewBuilder.m
//  Whitebox
//
//  Created by Olegs on 26/12/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import "CaptureViewBuilder.h"

@implementation CaptureViewBuilder

+ (NSMenuItem *) buildMenuItem:(Capture *)capture {
    NSMenuItem *menu_item = [[NSMenuItem alloc] init];
    
    switch (capture.type.intValue) {
        case CAPTURE_TYPE_SCREEN_IMG:;
            NSDateFormatter *date_formatter = [[NSDateFormatter alloc] init];
            NSDate *created_at = capture.created_at;
            [date_formatter setDateFormat:[WhiteBox valueForPathKey:@"View.Menu.Date.Format"]];
            NSString *title = [date_formatter stringFromDate:created_at];
            menu_item.title = title;
            break;
//        default:
//            break;
    }
    
    return menu_item;
}

@end
