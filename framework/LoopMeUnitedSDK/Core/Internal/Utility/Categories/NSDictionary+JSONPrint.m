//
//  NSString+NSString_JSONPrint.m
//  Tester
//
//  Created by Bohdan on 7/9/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

#import "NSDictionary+JSONPrint.h"

@implementation NSDictionary (JSONPrint)

- (NSString *)lm_jsonStringWithPrettyPrint: (BOOL)prettyPrint {
    NSError *error;
    NSJSONWritingOptions options = (NSJSONWritingOptions)(prettyPrint ? NSJSONWritingPrettyPrinted : 0);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: self options: options error: &error];
    if (!jsonData) {
        NSLog(@"%s: error: %@", __func__, error.localizedDescription);
        return @"{}";
    }
    return [[NSString alloc] initWithData: jsonData encoding: NSUTF8StringEncoding];
}

@end
