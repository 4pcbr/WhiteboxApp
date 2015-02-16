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
    NSDictionary *options = [self instance]->options;
    int ix = 0;
    int path_len = (int)[path_key_chain count];
    id ptr = options;
    while (ix < path_len) {
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

+ (NSDictionary *) flattenState:(NSDictionary *)original_dict {
    NSMutableDictionary *flatten_dict = [[NSMutableDictionary alloc] init];
    NSString *complete_key;
    for (NSString *key in original_dict) {
        if ([[original_dict objectForKey:key] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *flatten_thread = [self flattenState:[original_dict objectForKey:key]];
            for (NSString *sub_key in flatten_thread) {
                complete_key = [NSString stringWithFormat:@"%@%@%@", key, @KEY_SEPARATOR, sub_key];
                [flatten_dict setObject:[flatten_thread valueForKey:sub_key] forKey:complete_key];
            }
        } else {
            [flatten_dict setObject:[original_dict valueForKey:key] forKey:key];
        }
    }
    
    return flatten_dict;
}

+ (void) saveState:(NSManagedObjectContext *)manged_object_context {
    // TODO
    NSDictionary *flatten_dict = [self flattenState:[self instance]->options];
    NSLog(@"Flatten object: %@", flatten_dict);
}

+ (void) reloadState:(NSManagedObjectContext *)manged_object_context {
    // TODO
}

@end
