//
//  NSString+MD5.m
//  Tester
//
//  Created by Bohdan on 3/15/17.
//  Copyright © 2017 LoopMe. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "NSString+Encryption.h"
#import "NSData+LoopMeAES128.h"

@implementation NSString (Encryption)

+ (NSString *)lm_MD5:(NSString *)key {
    const char *ptr = [key UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x",md5Buffer[i]];
    }
    
    return output;
}

- (NSString *)lm_MD5 {
    return [NSString lm_MD5:self];
}

- (NSString *)lm_AES128Encrypt {
    NSData *stringData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedData = [stringData lm_AES128Encrypt];
    return [encryptedData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

- (NSString *)lm_stringByAddingPercentEncodingForRFC3986 {
    NSString *unreserved = @"-._~/?";
    NSMutableCharacterSet *allowed = [NSMutableCharacterSet
                                      alphanumericCharacterSet];
    [allowed addCharactersInString:unreserved];
    return [self
            stringByAddingPercentEncodingWithAllowedCharacters:
            allowed];
}

@end
