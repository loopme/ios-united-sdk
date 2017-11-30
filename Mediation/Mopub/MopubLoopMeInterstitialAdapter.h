//
//  MopubLoopMeInterstitialAdapter.h
//  Bridge
//


#import "MPInterstitialCustomEvent.h"
#import "LoopMeInterstitial.h"

@interface MopubLoopMeInterstitialAdapter : MPInterstitialCustomEvent
<
    LoopMeInterstitialDelegate
>

@property (nonatomic, strong) LoopMeInterstitial *loopmeInterstitial;

@end
