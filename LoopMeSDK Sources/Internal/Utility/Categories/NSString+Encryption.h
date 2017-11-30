//
//  NSString+MD5.h
//  Tester
//
//  Created by Bohdan on 3/15/17.
//  Copyright © 2017 LoopMe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Encryption)

+ (nullable NSString *)lm_MD5:(nonnull NSString *)key;
- (nullable NSString *)lm_MD5;
- (nullable NSString *)lm_AES128Encrypt;
- (nullable NSString *)lm_stringByAddingPercentEncodingForRFC3986;

@end
