//
//  MopubLoopMeRewardedVideoAdapter.h
//  Bridge
//


#import "MPRewardedVideoCustomEvent.h"
#import <LoopMeUnitedSDK/LoopMeInterstitial.h>

@interface MopubLoopMeRewardedVideoAdapter : MPRewardedVideoCustomEvent
<
    LoopMeInterstitialDelegate
>

@property (nonatomic, strong) LoopMeInterstitial *loopmeInterstitial;

@end
