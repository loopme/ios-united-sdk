//
//  NSString+NSString_JSONPrint.m
//  Tester
//
//  Created by Bohdan on 7/9/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

#import "NSDictionary+JSONPrint.h"

@implementation NSDictionary (JSONPrint)

- (NSString *)lm_jsonStringWithPrettyPrint:(BOOL)prettyPrint {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:(NSJSONWritingOptions)(prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if (!jsonData) {
        NSLog(@"%s: error: %@", __func__, error.localizedDescription);
        return @"{}";
    } else {
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return json;
    }
}

@end
