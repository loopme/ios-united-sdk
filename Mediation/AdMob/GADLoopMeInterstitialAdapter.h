//
//  GADLoopMeInterstitialAdapter.h
//  Bridge
//
//  Copyright (c) 2013 LoopMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoopMeInterstitial.h"

@import GoogleMobileAds;

@interface GADLoopMeInterstitialAdapter : NSObject
<
    GADCustomEventInterstitial,
    LoopMeInterstitialDelegate
>

@property (nonatomic, strong) LoopMeInterstitial *loopMeInterstitial;

@end
