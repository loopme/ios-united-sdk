//
//  MopubLoopMeRewardedVideoAdapter.h
//  Bridge
//


#import "MPRewardedVideoCustomEvent.h"
#import "LoopMeInterstitial.h"

@interface MopubLoopMeRewardedVideoAdapter : MPRewardedVideoCustomEvent
<
    LoopMeInterstitialDelegate
>

@property (nonatomic, strong) LoopMeInterstitial *loopmeInterstitial;

@end
