//
//  TestLocalFileStoragePlugin.m
//  Whitebox
//
//  Created by Olegs on 18/01/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LocalFileStoragePlugin.h"
#import <PromiseKit/Promise.h>
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>


@interface TestLocalFileStoragePlugin : XCTestCase
@end

@implementation TestLocalFileStoragePlugin

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testCanHandleImageCaptureEvent {
    Session *session = [[Session alloc] initWithSSID:1];
    
    id capture = OCMClassMock([Capture class]);
    
    
    OCMStub([capture created_at]).andReturn([NSDate date]);
    
    NSMutableDictionary *session_context = [[NSMutableDictionary alloc] init];
    [session_context setValue:capture forKey:@SHRD_CTX_CAPTURE_MNGD_OBJ];
    [session setContext:session_context];
    
    NSDictionary *plugin_options = [[NSDictionary alloc] initWithObjectsAndKeys: nil];
    
    LocalFileStoragePlugin *plugin = [[LocalFileStoragePlugin alloc] initPluginWithOptions:plugin_options];
    
    XCTAssert([plugin canHandleEvent:RE_SCREEN_CAPTURE_CREATED forSession:session], @"LocalFileStoragePlugin can handle Image capture event");
}

@end
