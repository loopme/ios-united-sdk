//
//  LoopMeSDK.h
//  LoopMeSDK
//
//  Created by Bohdan on 8/7/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import<AppTrackingTransparency/AppTrackingTransparency.h>

//! Project version number for LoopMeUnitedSDK.
FOUNDATION_EXPORT double LoopMeUnitedSDKVersionNumber;

//! Project version string for LoopMeSDK.
FOUNDATION_EXPORT const unsigned char LoopMeUnitedSDKVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <LoopMeUnitedSDK/PublicHeader.h>
#import <LoopMeUnitedSDK/LoopMeLogging.h>
#import <LoopMeUnitedSDK/LoopMeInterstitial.h>
#import <LoopMeUnitedSDK/LoopMeError.h>
#import <LoopMeUnitedSDK/LoopMeAdView.h>
#import <LoopMeUnitedSDK/LoopMeAdType.h>
#import <LoopMeUnitedSDK/LoopMeGDPRTools.h>
#import <LoopMeUnitedSDK/LoopMeSDKConfiguration.h>
#import <LoopMeUnitedSDK/LoopMeVPAIDError.h>
#import <LoopMeUnitedSDK/LoopMeOMIDWrapper.h>
#import <LoopMeUnitedSDK/LoopMeDefinitions.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoopMeSDK : NSObject
    
@property (nonatomic, readonly) BOOL isReady;

+ (NSString *)version;

+ (instancetype)shared;
+ (NSBundle *)resourcesBundle;

    
- (void)initSDKFromRootViewController:(UIViewController *)rootViewController
                     sdkConfiguration:(LoopMeSDKConfiguration *) configuration
                     completionBlock :(void(^_Nullable)(BOOL,  NSError * _Nullable))completionBlock;
    
- (void)initSDKFromRootViewController:(UIViewController *)rootViewController completionBlock :(void(^_Nullable)(BOOL, NSError * _Nullable))completionBlock;
    
@end

NS_ASSUME_NONNULL_END
