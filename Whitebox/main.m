//
//  main.m
//  Whitebox2
//
//  Created by Olegs on 02/01/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define DEBUG_MODE

#ifdef DEBUG_MODE
#define DebugLog( s, ... ) NSLog( @"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define DebugLog( s, ... )
#endif

int main(int argc, const char * argv[]) {
    return NSApplicationMain(argc, argv);
}
