//
//  LoopmeMediationAdapter.h
//  Applovin-mediation-sample
//
//  Created by Volodymyr Novikov on 29.06.2022.
//

#ifndef LoopMeAdapter_h
#define LoopMeAdapter_h

#import <AppLovinSDK/AppLovinSDK.h>

@interface LoopmeMediationAdapter: ALMediationAdapter<MAInterstitialAdapter, MAAdViewAdapter, MARewardedAdapter>

- (NSString *_Nonnull)SDKVersion;
- (NSString *_Nonnull)adapterVersion;
- (void)destroy;

@end

#endif /* LoopMeAdapter_h */
