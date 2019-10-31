//
//  LoopMeSDK.h
//  LoopMeSDK
//
//  Created by Bohdan on 8/7/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for LoopMeSDK.
FOUNDATION_EXPORT double LoopMeSDKVersionNumber;

//! Project version string for LoopMeSDK.
FOUNDATION_EXPORT const unsigned char LoopMeSDKVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <LoopMeSDK/PublicHeader.h>
#import <LoopMeSDK/LoopMeLogging.h>
#import <LoopMeSDK/LoopMeInterstitial.h>
#import <LoopMeSDK/LoopMeError.h>
#import <LoopMeSDK/LoopMeAdView.h>
#import <LoopMeSDK/LoopMeAdType.h>
#import <LoopMeSDK/LoopMeGDPRTools.h>
#import <LoopMeSDK/LoopMeSDKConfiguration.h>
#import <LoopMeSDK/LoopMeVPAIDError.h>
#import <LoopMeSDK/LoopMeOMIDWrapper.h>
#import <LoopMeSDK/LoopMeDefinitions.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoopMeSDK : NSObject
    
@property (nonatomic, readonly) BOOL isReady;

+ (NSString *)version;

+ (instancetype)shared;
    
- (void)initSDKFromRootViewController:(UIViewController *)rootViewController
                     sdkConfiguration:(LoopMeSDKConfiguration *) configuration
                     completionBlock :(void(^_Nullable)(BOOL,  NSError * _Nullable))completionBlock;
    
- (void)initSDKFromRootViewController:(UIViewController *)rootViewController completionBlock :(void(^_Nullable)(BOOL, NSError * _Nullable))completionBlock;
    
@end

NS_ASSUME_NONNULL_END
