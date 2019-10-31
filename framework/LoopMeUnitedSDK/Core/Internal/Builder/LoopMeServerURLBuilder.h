//
//  LoopMeServerURLBuilder.h
//  LoopMeSDK
//
//  Created by Dmitriy Lihachov on 07/11/13.
//  Copyright (c) 2013 LoopMe. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
@class LoopMeTargeting;

@interface LoopMeServerURLBuilder : NSObject

+ (NSString *)packageIDs;

+ (NSString *)parameterForBundleIdentifier;
+ (NSString *)parameterForUniqueIdentifier;

@end
