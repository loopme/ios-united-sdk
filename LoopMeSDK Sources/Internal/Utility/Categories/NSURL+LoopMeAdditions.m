//
//  NSURL+LoopMeAdditions.m
//  LoopMeSDK
//
//  Created by Dmitriy Lihachov on 11/11/13.
//  Copyright (c) 2013 LoopMe. All rights reserved.
//

#import "NSURL+LoopMeAdditions.h"

static const NSUInteger kLoopMeMaxDecodeIteration = 5;

@implementation NSURL (LoopMeAdditions)

- (NSDictionary *)lm_toDictionary {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSArray *elements = [self.query componentsSeparatedByString:@"&"];
    for (NSString *element in elements) {
        NSArray *keyVal = [element componentsSeparatedByString:@"="];
        if (keyVal.count >= 2) {
            NSString *key = keyVal[0];
            NSString *value = keyVal[1];
            dictionary[key] = [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        }
    }
    return dictionary;
}

+ (NSURL *)lm_urlWithEncodedString:(NSString *)string {
    for (int i = 0; i < kLoopMeMaxDecodeIteration; i++) {
        if ([string containsString:@"%"]) {
            string = [string stringByRemovingPercentEncoding];
        } else {
            break;
        }
    }
    return [self URLWithString:string];
}

@end
