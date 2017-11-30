//
//  LoopMeConverter.h
//  LoopMeSDK
//
//  Copyright © 2016 LoopMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import "LoopMeSkipOffset.h"

@interface LoopMeVPAIDConverter : NSObject

+ (CMTime)timeFromString:(NSString *)string;
+ (LoopMeSkipOffset)skipOffsetFromString:(NSString *)string;

@end
