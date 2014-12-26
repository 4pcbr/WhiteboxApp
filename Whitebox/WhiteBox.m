//
//  WhiteBox.m
//  Whitebox
//
//  Created by Olegs on 25/12/14.
//  Copyright (c) 2014 Brand New Heroes. All rights reserved.
//

#import "WhiteBox.h"

#define KEY_SEPARATOR "."

@implementation WhiteBox {
    NSMutableDictionary *options;
}

WhiteBox *_instance;
+ (WhiteBox *) instance {
    if (_instance == NULL) {
        _instance = [[WhiteBox alloc] init];
    }
    return _instance;
}

+ (void) setOptions:(NSDictionary *)options_ {
    [self instance]->options = [[NSMutableDictionary alloc] initWithDictionary:options_];
    NSLog(@"I got a batch of settings and the current state is: %@",
          [self instance]->options);
}

+ (void) setValue:(id)value ForPathKey:(NSString *)path_key {
    NSArray *path_key_chain = [self pathKeyChain:path_key];
    NSMutableDictionary *options = [self instance]->options;
    int ix = 0;
    int path_len = (int)[path_key_chain count];
    id ptr = options;
    id prev_ptr = options;
    while (ix < path_len - 1) {
        ptr = [prev_ptr valueForKey:path_key_chain[ix]];
        if (ptr == NULL) {
            ptr = [[NSMutableDictionary alloc] init];
            [prev_ptr setObject:ptr forKey:path_key_chain[ix]];
        }
        if (![ptr isKindOfClass:[NSDictionary class]]) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:[NSString stringWithFormat:@"Can't modify a non-dictionary node in %@", NSStringFromSelector(_cmd)]
                                         userInfo:nil];
        }
            
        ix++;
        prev_ptr = ptr;
    }
    [ptr setObject:value forKey:path_key_chain[ix]];
}

+ (id) valueForPathKey:(NSString *)path_key {
    NSArray *path_key_chain = [self pathKeyChain:path_key];
    NSLog(@"Path key chain: %@", path_key_chain);
    NSDictionary *options = [self instance]->options;
    int ix = 0;
    int path_len = (int)[path_key_chain count];
    id ptr = options;
    while (ix < path_len) {
        NSLog(@"Testing component: %@ at the index: %i", path_key_chain[ix], ix);
        ptr = [ptr valueForKey:path_key_chain[ix]];
        if (ptr == NULL) {
            break;
        }
        ix++;
    }
    
    return ptr;
}

+ (NSArray *)pathKeyChain:(NSString *)path_key {
    return [path_key componentsSeparatedByString:@KEY_SEPARATOR];
}

@end
