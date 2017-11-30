//
//  LoopMeConverter.m
//  LoopMeSDK
//
//  Copyright © 2016 LoopMe. All rights reserved.
//

#import "LoopMeVPAIDConverter.h"

@implementation LoopMeVPAIDConverter

+ (CMTime)timeFromString:(NSString *)string {
    if (!string) {
        return kCMTimeZero;
    }
    int hours, minutes, seconds;
    NSScanner *timeScanner = [[NSScanner alloc] initWithString:string];
    [timeScanner scanInt:&hours];
    [timeScanner scanString:@":" intoString:nil];
    [timeScanner scanInt:&minutes];
    [timeScanner scanString:@":" intoString:nil];
    [timeScanner scanInt:&seconds];
    
    double totalSec = hours*60*60 + minutes*60 + seconds;
    if (totalSec == 0) {
        return kCMTimeZero;
    }
    
    return CMTimeMake(totalSec, 1);
}

+ (LoopMeSkipOffset)skipOffsetFromString:(NSString *)string {
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"-" withString:@""];
    if (!string.length) {
        return kLoopMeSkipOffsetZero;
    } else if ([string containsString:@"%"]) {
        return [self timeFromPercentString:string];
    } else {
        return [self timeFromTimeString:string];
    }
}

+ (LoopMeSkipOffset)timeFromPercentString:(NSString *)string {
    LoopMeSkipOffset skipOffset;
    skipOffset.type = LoopMeSkipOffsetTypePercentage;
    
    int time;
    NSScanner *timeScanner = [[NSScanner alloc] initWithString:string];
    [timeScanner scanInt:&time];
    [timeScanner scanString:@"%" intoString:nil];
    
    skipOffset.value = time;
    return skipOffset;
}

+ (LoopMeSkipOffset)timeFromTimeString:(NSString *)string {
    LoopMeSkipOffset skipOffset;
    skipOffset.type = LoopMeSkipOffsetTypeSec;
    
    int hours, minutes, seconds;
    NSScanner *timeScanner = [[NSScanner alloc] initWithString:string];
    [timeScanner scanInt:&hours];
    [timeScanner scanString:@":" intoString:nil];
    [timeScanner scanInt:&minutes];
    [timeScanner scanString:@":" intoString:nil];
    [timeScanner scanInt:&seconds];
    
    double totalSec = hours*60*60 + minutes*60 + seconds;
    skipOffset.value = totalSec;
    return skipOffset;
}

@end
