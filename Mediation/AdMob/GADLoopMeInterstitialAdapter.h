//
//  GADLoopMeInterstitialAdapter.h
//  Bridge
//
//  Copyright (c) 2013 LoopMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LoopMeUnitedSDK/LoopMeSDK.h>
#import <LoopMeUnitedSDK/LoopMeInterstitial.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface GADLoopMeInterstitialAdapter : NSObject
<
    GADCustomEventInterstitial,
    LoopMeInterstitialDelegate
>

@property (nonatomic, strong) LoopMeInterstitial *loopMeInterstitial;

@end
