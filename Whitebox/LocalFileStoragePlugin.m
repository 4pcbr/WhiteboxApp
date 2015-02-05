//
//  LocalFileStorage.m
//  Whitebox
//
//  Created by Olegs on 23/11/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import "LocalFileStoragePlugin.h"

@implementation LocalFileStoragePlugin

static NSDictionary *__dispatch_table__;

- (void) initDispatchTable {
    @synchronized(self) {
        __dispatch_table__ = @{
                        @RE_SCREEN_CAPTURE_CREATED: @"storeFile:",
                        @RE_REQUEST_RESTORE_FH: @"fillFH:"
                       };
    }
}

- (BOOL) canHandleEvent:(int)event_id forSession:(Session *)session {

    if (__dispatch_table__ == nil) {
        [self initDispatchTable];
    }
    
    NSString *sel_str = [__dispatch_table__ objectForKey:[NSNumber numberWithInt:event_id]];
    
    if (sel_str == nil) {
        NSLog(@"Don't know how to handle an event with this ID: %d", event_id);
        return NO;
    }
    
//    NSLog(@"Dispatch table: %@", __dispatch_table__);
    
    if (event_id != RE_SCREEN_CAPTURE_CREATED &&
        event_id != RE_REQUEST_RESTORE_FH) {
        NSLog(@"Don't know how to handle an event with this ID");
        return NO;
    };
    
    Capture *capture = [[session context] valueForKey:@SHRD_CTX_CAPTURE_MNGD_OBJ];
    
    NSLog(@"%@", capture);
    
    if (!capture) {
        NSLog(@"No capture in the reactor data provided");
        return NO;
    }
    
    if (capture.type.intValue != CAPTURE_TYPE_SCREEN_IMG) {
        NSLog(@"Non-image type capture provided");
        return NO;
    }
    
    return YES;
}

- (PMKPromise *) dispatch:(Session *)session {
    
    if (__dispatch_table__ == nil) {
        [self initDispatchTable];
    }
    
    int event_id = session.eventID;
    
    NSString *sel_str = [__dispatch_table__ objectForKey:[NSNumber numberWithInt:event_id]];
    
    NSLog(@"Dispatch table: %@", __dispatch_table__);
    
    NSLog(@"Event id: %d", event_id);
    
    NSLog(@"Selector to be sent: %@", sel_str);
    
    SEL sel = NSSelectorFromString(sel_str);
    return [self performSelector:sel withObject:session];
}

- (PMKPromise *) fillFH:(Session *)session {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        NSLog(@"Hello fillFH!");
        fulfill(session);
    }];
}

- (PMKPromise *) run:(Session *)session {
    return [self dispatch:session];
}

- (PMKPromise *) storeFile:(Session *)session {
    
    NSLog(@"Store the local file");
    
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        NSDictionary *event_data          = [session context];
        Capture      *capture             = [event_data valueForKey:@SHRD_CTX_CAPTURE_MNGD_OBJ];
        NSFileHandle *input_file          = [event_data valueForKey:@SHRD_CTX_TMP_FILE_HANDLE];
        NSString     *yyyymmddhhiiss_name = [event_data valueForKey:@SHRD_CTX_YYYYMMDDHHIISS_FILE_NAME];
        NSString     *file_ext            = [WhiteBox valueForPathKey:@"Capture.Screen.FileExtension"];
        
        if (yyyymmddhhiiss_name == NULL) {
            yyyymmddhhiiss_name = [Utils yyyymmddhhiiss];
            [event_data setValue:yyyymmddhhiiss_name forKey:@SHRD_CTX_YYYYMMDDHHIISS_FILE_NAME];
        }
        
        NSString *file_name = [self filePathFor:
                                    [NSString stringWithFormat:@"%@.%@",
                                        yyyymmddhhiiss_name,
                                        file_ext]
                               ];
        NSString *destination_folder = [(NSString *)[self->options valueForKey:@"StorePath"] stringByStandardizingPath];
        
        NSError *create_folder_error;
        
        BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:destination_folder withIntermediateDirectories:YES attributes:nil error:&create_folder_error];
        
        if (!success || create_folder_error) {
            NSLog(@"Error creating folder %@", destination_folder);
            return reject(create_folder_error);
        }
        
        NSFileHandle *output_file = [NSFileHandle fileHandleForWritingAtPath:file_name];
        
        if (output_file == nil) {
            [[NSFileManager defaultManager] createFileAtPath:file_name contents:nil attributes:nil];
            output_file = [NSFileHandle fileHandleForWritingAtPath:file_name];
        }
        NSString *failed_assert_msg = [NSString stringWithFormat:@"Failed to create the destination file, %@", file_name];
        NSAssert(output_file != nil, failed_assert_msg);
        
        NSLog(@"The file name: %@", file_name);
        
        NSAssert(input_file != nil, @"Input file handle can not be nil");
        
        NSData *buffer;
        
        @try {
            [input_file seekToFileOffset:0];
            [output_file seekToFileOffset:0];
            
            while ([(buffer = [input_file readDataOfLength:1024]) length] > 0) {
                [output_file writeData:buffer];
            }
            NSLog(@"Done copying the file");
            
            NSDictionary *capture_data_dict = [[NSDictionary alloc] initWithObjectsAndKeys:
               file_name, @"meta",
               [self signature], @"provider",
               [NSNumber numberWithInt:CAPTURE_DATA_STATUS_OK ], @"status",
               nil
            ];
            
            NSLog(@"CaptureData dictionary: %@", capture_data_dict);
            
            [capture addCaptureDataFromDictionary:capture_data_dict];
        }
        @catch (NSException *exception) {
            @throw;
        }
        @finally {
            [input_file seekToFileOffset:0];
            [output_file closeFile];
            fulfill(capture);
        }
    }];
}

- (NSString *) filePathFor:(NSString *)file_name {
    NSString *destination_folder = [(NSString *)[self->options valueForKey:@"StorePath"] stringByStandardizingPath];
    NSString *file_path = [[NSString stringWithFormat:@"%@/%@",
                           destination_folder,
                           file_name] stringByStandardizingPath];
    return file_path;
}

- (id<ReactorPluginViewBuilder>) getViewBuilder {
    
    if (self->view_builder == NULL) {
        self->view_builder = [[LocalFileViewBuilder alloc] init];
    }
    
    return self->view_builder;
}

@end
