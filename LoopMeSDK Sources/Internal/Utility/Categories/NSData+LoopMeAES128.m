//
//  NSData+LoopMeAES256.m
//
//  Created by Bohdan on 3/1/16.
//  Copyright © 2016 LoopMe. All rights reserved.
//

#import <CommonCrypto/CommonCryptor.h>
#import "NSData+LoopMeAES128.h"

const char encryptionKey[] =  {
    0xfa, 0x62, 0x44, 0xa2,
    0x97, 0xa4, 0xba, 0x03,
    0x2e, 0x89, 0xde, 0x9b,
    0x77, 0xf3, 0xa2, 0xf9
};

@implementation NSData (LoopMeAES128)

- (NSData *)lm_AES128Encrypt {
    
    NSUInteger dataLength = [self length];
    

    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          encryptionKey, kCCKeySizeAES128,
                                          NULL,
                                          [self bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer);
    return nil;
}

@end
