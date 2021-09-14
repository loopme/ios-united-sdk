//
//  MopubLoopMeRewardedVideoAdapter.h
//  Bridge
//


#import <MPFullscreenAdAdapter.h>
#import "LoopMeUnitedSDK/LoopMeInterstitial.h"

@interface MopubLoopMeRewardedVideoAdapter : MPFullscreenAdAdapter
<
    MPThirdPartyFullscreenAdAdapter
>

@property (nonatomic, strong) LoopMeInterstitial *loopmeInterstitial;

@end
