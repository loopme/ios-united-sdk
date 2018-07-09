//
//  LoopMeVASTMacroProcessor.m
//  LoopMeSDK
//
//  Copyright (c) 2018 LoopMe. All rights reserved.
//

#import "LoopMeVASTMacroProcessor.h"
#import "NSString+Encryption.h"

@implementation LoopMeVASTMacroProcessor

+ (NSURL *)macroExpandedURLForURL:(NSURL *)URL errorCode:(NSInteger)errorCode
{
    return [self macroExpandedURLForURL:URL errorCode:errorCode videoTimeOffset:-1 videoAssetURL:nil];
}

+ (NSURL *)macroExpandedURLForURL:(NSURL *)URL errorCode:(NSInteger)errorCode videoTimeOffset:(NSTimeInterval)timeOffset videoAssetURL:(NSURL *)assetURL
{
    NSMutableString *URLString = [[URL absoluteString] mutableCopy];

    NSString *stringErrorCode = [NSString stringWithFormat:@"%ld", (long)errorCode];
    NSString *trimmedErrorCode = [stringErrorCode stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([trimmedErrorCode length]) {
        [URLString replaceOccurrencesOfString:@"[ERRORCODE]" withString:stringErrorCode options:0 range:NSMakeRange(0, [URLString length])];
        [URLString replaceOccurrencesOfString:@"%5BERRORCODE%5D" withString:stringErrorCode options:0 range:NSMakeRange(0, [URLString length])];
    }

    if (timeOffset >= 0) {
        NSString *timeOffsetString = [self stringFromTimeInterval:timeOffset];
        [URLString replaceOccurrencesOfString:@"[CONTENTPLAYHEAD]" withString:timeOffsetString options:0 range:NSMakeRange(0, [URLString length])];
        [URLString replaceOccurrencesOfString:@"%5BCONTENTPLAYHEAD%5D" withString:timeOffsetString options:0 range:NSMakeRange(0, [URLString length])];
    }

    if (assetURL) {
        NSString *encodedAssetURLString = [[assetURL absoluteString] lm_stringByAddingPercentEncodingForRFC3986];
        [URLString replaceOccurrencesOfString:@"[ASSETURI]" withString:encodedAssetURLString options:0 range:NSMakeRange(0, [URLString length])];
        [URLString replaceOccurrencesOfString:@"%5BASSETURI%5D" withString:encodedAssetURLString options:0 range:NSMakeRange(0, [URLString length])];
    }

    NSString *cachebuster = [NSString stringWithFormat:@"%u", arc4random() % 90000000 + 10000000];
    [URLString replaceOccurrencesOfString:@"[CACHEBUSTING]" withString:cachebuster options:0 range:NSMakeRange(0, [URLString length])];
    [URLString replaceOccurrencesOfString:@"%5BCACHEBUSTING%5D" withString:cachebuster options:0 range:NSMakeRange(0, [URLString length])];
    

    NSString *timestampString = [self timeStampISO8601String];
    [URLString replaceOccurrencesOfString:@"[TIMESTAMP]" withString:timestampString options:0 range:NSMakeRange(0, [URLString length])];
    [URLString replaceOccurrencesOfString:@"%5BTIMESTAMP%5D" withString:timestampString options:0 range:NSMakeRange(0, [URLString length])];

    return [NSURL URLWithString:URLString];
}

+ (NSString *)timeStampISO8601String {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    
    NSDate *now = [NSDate date];
    NSString *iso8601String = [dateFormatter stringFromDate:now];
    return iso8601String;
}

+ (NSString *)stringFromTimeInterval:(NSTimeInterval)timeInterval
{
    if (timeInterval < 0) {
        return @"00:00:00.000";
    }
    
    NSInteger flooredTimeInterval = (NSInteger)timeInterval;
    NSInteger hours = flooredTimeInterval / 3600;
    NSInteger minutes = (flooredTimeInterval / 60) % 60;
    NSTimeInterval seconds = fmod(timeInterval, 60);
    return [NSString stringWithFormat:@"%02ld:%02ld:%06.3f", (long)hours, (long)minutes, seconds];
}
    
@end
