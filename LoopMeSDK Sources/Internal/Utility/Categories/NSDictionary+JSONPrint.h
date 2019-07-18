//
//  NSString+NSString_JSONPrint.h
//  Tester
//
//  Created by Bohdan on 7/9/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (JSONPrint)

- (NSString *)lm_jsonStringWithPrettyPrint:(BOOL)prettyPrint;

@end

NS_ASSUME_NONNULL_END
