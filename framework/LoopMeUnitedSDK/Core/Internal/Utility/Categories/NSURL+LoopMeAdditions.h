//
//  NSURL+LoopMeAdditions
//  LoopMeSDK
//
//  Created by Dmitriy Lihachov on 11/11/13.
//  Copyright (c) 2013 LoopMe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (LoopMeAdditions)

- (NSDictionary *)lm_toDictionary;
+ (NSURL *)lm_urlWithEncodedString:(NSString *)string;

@end
