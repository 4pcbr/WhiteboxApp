//
//  ReactorEvents.h
//  Whitebox
//
//  Created by Olegs on 27/11/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#ifndef Whitebox_ReactorEvents_h
#define Whitebox_ReactorEvents_h

// End Of Cycle
#define RE_EOC                       10

// BEGIN Screen capture storage events

#define RE_SCREEN_CAPTURE_CREATED    100
#define RE_LOCAL_FILE_CREATED        110
#define RE_REQUEST_RESTORE_FH        120


// Custom SFTP plugin events
#define RE_PLUGIN_SFTP_UPLOAD        100 << 2
//#define RE_PLUGIN_SFTP_REUPLOAD      101 << 2

// Custom REST plugin events
#define RE_PLUGIN_REST_UPLOAD        110 << 2
//#define RE_PLUGIN_REST_REUPLOAD      111 << 2

// END Screen capture storage events

#endif
