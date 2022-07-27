//
//  LoopMeAdapter.h
//  Applovin-mediation-sample
//
//  Created by Volodymyr Novikov on 29.06.2022.
//

#ifndef LoopMeAdapter_h
#define LoopMeAdapter_h

#import <AppLovinSDK/ALMediationAdapter.h>
#import <LoopMeUnitedSDK/LoopMeInterstitial.h>

@interface LoopmeMediationAdapter: ALMediationAdapter<MAInterstitialAdapter, LoopMeInterstitialDelegate>

- (NSString *_Nonnull)SDKVersion;
- (NSString *_Nonnull)adapterVersion;
- (void)destroy;

@end

#endif /* LoopMeAdapter_h */
