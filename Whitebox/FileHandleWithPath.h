//
//  FileHandleWithPath.h
//  Whitebox
//
//  Created by Olegs on 21/01/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileHandleWithPath : NSFileHandle

@property (strong, nonatomic) NSString *file_path;

@end


@interface FileHandleWithPath (NSFileHandleCreation)

+ (instancetype)fileHandleForReadingAtPath:(NSString *)path;
+ (instancetype)fileHandleForWritingAtPath:(NSString *)path;
+ (instancetype)fileHandleForUpdatingAtPath:(NSString *)path;

@end