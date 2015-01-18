//
//  SessionManager.h
//  Whitebox
//
//  Created by Olegs on 14/01/15.
//  Copyright (c) 2015 Brand New Heroes. All rights reserved.
//

#include <stdlib.h>

#import <Foundation/Foundation.h>
#import "Session.h"

@interface SessionManager : NSObject

@property (strong, nonatomic) NSMutableDictionary *sessions;

+ (Session *) createSession;

+ (Session *) retrieveSessionBySSID:(uint16)ssid;

@end
