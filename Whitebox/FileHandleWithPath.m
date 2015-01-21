//
//  FileHandleWithPath.m
//  Whitebox
//
//  Created by Olegs on 21/01/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import "FileHandleWithPath.h"

@implementation FileHandleWithPath

@end

@implementation FileHandleWithPath(NSFileHandleCreation)

+ (instancetype) fileHandleForReadingAtPath:(NSString *)path {
    FileHandleWithPath *res = [super fileHandleForReadingAtPath:path];
    if (res != nil) {
        res.file_path = path;
    }
    
    return res;
}

+ (instancetype)fileHandleForWritingAtPath:(NSString *)path {
    FileHandleWithPath *res = [super fileHandleForWritingAtPath:path];
    if (res != nil) {
        res.file_path = path;
    }
    
    return res;
}

+ (instancetype)fileHandleForUpdatingAtPath:(NSString *)path {
    FileHandleWithPath *res = [super fileHandleForUpdatingAtPath:path];
    if (res != nil) {
        res.file_path = path;
    }
    
    return res;
}

@end