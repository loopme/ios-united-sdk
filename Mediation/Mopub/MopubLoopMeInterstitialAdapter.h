//
//  MopubLoopMeInterstitialAdapter.h
//  Bridge
//


#import "MPInterstitialCustomEvent.h"
#import <LoopMeUnitedSDK/LoopMeInterstitial.h>

@interface MopubLoopMeInterstitialAdapter : MPInterstitialCustomEvent
<
    LoopMeInterstitialDelegate
>

@property (nonatomic, strong) LoopMeInterstitial *loopmeInterstitial;

@end
