//
//  ImageFileCapture.h
//  Whitebox
//
//  Created by Olegs on 24/11/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Capture.h"

@interface ImageFileCapture : Capture

@property (nonatomic, strong, readwrite) NSString     * name;
@property (nonatomic, strong, readwrite) NSFileHandle * file;

@end
