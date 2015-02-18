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
        _instance->options = [[NSMutableDictionary alloc] init];
    }
    return _instance;
}

+ (void) setOptions:(NSDictionary *)options_ {
    for (NSString *key in options_) {
        [self setValue:[options_ objectForKey:key] ForPathKey:key];
    }
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
        id value = [original_dict objectForKey:key];
        if ([value isKindOfClass:[NSDictionary class]]) {
            NSDictionary *flatten_thread = [self flattenState:value];
            for (NSString *sub_key in flatten_thread) {
                complete_key = [NSString stringWithFormat:@"%@%@%@", key, @KEY_SEPARATOR, sub_key];
                [flatten_dict setObject:[flatten_thread valueForKey:sub_key] forKey:complete_key];
            }
        } else if ([value isKindOfClass:[NSString class]] ||
                   [value isKindOfClass:[NSNumber class]]) {
            [flatten_dict setObject:value forKey:key];
        } else {
            NSLog(@"Can not flatten object %@", value);
        }
    }
    
    return flatten_dict;
}

+ (BOOL) saveState:(NSManagedObjectContext *)context {
    
    NSDictionary *flatten_dict = [self flattenState:[self instance]->options];
    NSLog(@"Flatten object: %@", flatten_dict);
    
    for (NSString *key in flatten_dict) {
        id value = [flatten_dict objectForKey:key];
        [self createOrUpdate:key withValue:value inManagedObjectContext:context];
    }
    
    if ([context hasChanges]) {
        NSError *__autoreleasing *error;
        if (![context save:error]) {
            // TODO: handle it!
            return NO;
        }
    }
    
    return YES;
}

+ (BOOL) createOrUpdate:(NSString *)key withValue:(id)value inManagedObjectContext:(NSManagedObjectContext *)context {
    
    NSLog(@"Stringified value for key %@: %@, type: %i", key, [self stringifyValue:value], [self getValueType:value]);
    
    Settings       *settings_item   = nil;
    NSFetchRequest *request         = [[NSFetchRequest alloc] init];
    NSError *__autoreleasing *error = nil;
    
    request.entity    = [NSEntityDescription entityForName:@"Settings" inManagedObjectContext:context];
    request.predicate = [NSPredicate predicateWithFormat:@"key = %@", key];
    
    settings_item = [[context executeFetchRequest:request error:error] lastObject];
    
    if (settings_item == nil) {
        settings_item = [NSEntityDescription insertNewObjectForEntityForName:@"Settings" inManagedObjectContext:context];
        settings_item.key = key;
    }
    
    [settings_item setType:[NSNumber numberWithInt:[self getValueType:value]]];
    [settings_item setValue:[self stringifyValue:value]];
    
    return NO;
}

+ (NSString *) stringifyValue:(id)value {
    int attr_type = [self getValueType:value];
    
    if (attr_type == -1) {
        NSLog(@"Returning undefined value for an unknown value class");
        return @"";
    }
    
    switch (attr_type) {
        case STRING:
            return value;
            break;
        case INTEGER:
        case FLOAT:
        case BOOLEAN:
            return [NSString stringWithFormat:@"%@", value];
            break;
        default:
            NSLog(@"Got an unknown type in the if-case");
            return @"";
            break;
    }
}

+ (int) getValueType:(id)value {

    if ([value isKindOfClass:[NSString class]]) {
        return STRING;
    } else if ([value isKindOfClass:[NSNumber class]]) {
        if (strcmp([value objCType], @encode(BOOL)) == 0) {
            return BOOLEAN;
        } else if (strcmp([value objCType], @encode(int)) == 0) {
            return INTEGER;
        } else if (strcmp([value objCType], @encode(float)) == 0) {
            return FLOAT;
        }
    }

    NSLog(@"Unable to determine the type of the attribute: %@", value);
    
    return -1;
}

+ (void) loadState:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Settings"];
    NSError *__autoreleasing *error;
    NSArray *settings = [context executeFetchRequest:request error:error];
    for (Settings *settings_item in settings) {
        id value = [self parseValue:settings_item.value ofType:[settings_item.type intValue]];
        NSLog(@"Value: %@ for key: %@", value, settings_item.key);
        [self setValue:value ForPathKey:settings_item.key];
    }
    
    NSLog(@"Reloaded options: %@", [self instance]->options);
}

+ (id) parseValue:(NSString *)value ofType:(int)type {
    switch (type) {
        case STRING:
            return value;
        case INTEGER:
            return [NSNumber numberWithInt:[value intValue]];
        case FLOAT:
            return [NSNumber numberWithFloat:[value floatValue]];
        case BOOLEAN:
            return [NSNumber numberWithBool:[value boolValue]];
        default:
            return nil;
            break;
    }
}

@end
