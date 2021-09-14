//
//  MopubLoopMeInterstitialAdapter.h
//  Bridge
//

#import "MPFullscreenAdAdapter.h"
#import "LoopMeUnitedSDK/LoopMeInterstitial.h"

@interface MopubLoopMeInterstitialAdapter : MPFullscreenAdAdapter
<
    MPThirdPartyFullscreenAdAdapter
>

@property (nonatomic, strong) LoopMeInterstitial *loopmeInterstitial;

@end
