//
//  ScreenGrabber.m
//  Whitebox
//
//  Created by Olegs on 23/11/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import "ScreenGrabber.h"

@implementation ScreenGrabber

NSDictionary * _defaults_;

+ (NSString *) mkTmpWithTmpl:(NSString *)tmpl {
    char * tmp_file = mktemp((char*)[tmpl UTF8String]);
    return [NSString stringWithFormat:@"%s", tmp_file];
}

+ (PMKPromise *) capture:(NSDictionary *)options {

    if (!_defaults_) {
        _defaults_ = [[NSDictionary alloc] initWithObjectsAndKeys:
                    @"png", @"format",
                    @"/usr/sbin/screencapture", @"bin_path",
                    NSTemporaryDirectory(), @"dir",
                    nil];
    }
    
    NSMutableDictionary * settings = [[NSMutableDictionary alloc] init];
    
    [settings addEntriesFromDictionary:_defaults_];
    [settings addEntriesFromDictionary:options];
    
    NSLog(@"Screencapture settings: %@", settings);
    
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        NSString * format         = [settings valueForKey:@"format"];
        NSString * tmp_dir        = [settings valueForKey:@"dir"];
        NSString * bin_path       = [settings valueForKey:@"bin_path"];
        NSString * tmp_file_tmpl  = [NSString stringWithFormat:@"%@XXXXXX", tmp_dir];
        NSString * tmp_file       = [self mkTmpWithTmpl:tmp_file_tmpl];
        NSTask   * capture_task   = [[NSTask alloc] init];
        NSArray  * launch_options = [[NSArray alloc] initWithObjects:
                                     @"-x", // No sound
                                     @"-i", // Interactive mode: keyboard keys are supported
                                     [NSString stringWithFormat:@"-t%@", format], // Image format
                                     tmp_file,
                                     nil];
        
        NSLog(@"Screencapture launch_options: %@", launch_options);

        if (!bin_path) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"Screencapture bin path is not defined."
                                         userInfo:nil];
        }

        [capture_task setLaunchPath:bin_path];
        [capture_task setArguments:launch_options];
        [capture_task promise].then(^(NSData *data) {
            NSFileHandle *file_handle = [NSFileHandle fileHandleForReadingAtPath:tmp_file];
            fulfill(file_handle);
        }).catch(^(NSError *error) {
            reject(error);
        });
    }];
    
}

+ (void) capture:(NSDictionary *)options delegate:(id<ScreenGrabberDelegate>)delegate {
    [self capture:options].then(^(NSData * data) {
        [delegate screenGrabberComplete:(NSFileHandle *)data];
    }).catch(^(NSError * error) {
        [delegate screenGrabberFail:error];
    }).finally(^(void) {
        [delegate screenGrabberFinally];
    });
}

@end
