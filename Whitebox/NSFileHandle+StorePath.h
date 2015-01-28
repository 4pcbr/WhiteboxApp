//
//  NSFileHandle+StorePath.h
//  Whitebox
//
//  Created by Olegs on 28/01/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import <objc/runtime.h>
#import <Foundation/Foundation.h>

@interface NSFileHandle (StorePath)

@property (strong, nonatomic) NSString *file_path;

@end
