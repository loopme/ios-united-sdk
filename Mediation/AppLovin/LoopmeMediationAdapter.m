//
//  LoopMeAdapter.m
//  Applovin-mediation-sample
//
//  Created by Volodymyr Novikov on 29.06.2022.
//

#import <Foundation/Foundation.h>
#import "LoopmeMediationAdapter.h"
#import "LoopMeUnitedSDK/LoopMeSDK.h"
#import "AppLovinSDK/MAInterstitialAdapterDelegate.h"
#import "AppLovinSDK/MAAdapterError.h"

@implementation LoopmeMediationAdapter{
    LoopMeInterstitial *intersitial;
    id<MAInterstitialAdapterDelegate> intersititalDelegate;
}

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void(^)(MAAdapterInitializationStatus initializationStatus, NSString *_Nullable errorMessage))completionHandler{
    if ([[LoopMeSDK shared] isReady]){
        completionHandler(MAAdapterInitializationStatusInitializedSuccess, NULL);
    }else{
        completionHandler(MAAdapterInitializationStatusInitializedFailure, @"Loopme sdk has not been initialized!");
    }
}

- (NSString *) SDKVersion{
    return @"7.3.1";
}

- (NSString *)adapterVersion{
    return @"1.0.0";
}

- (void)destroy {}


- (void)loadInterstitialAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters andNotify:(nonnull id<MAInterstitialAdapterDelegate>)delegate {
    intersititalDelegate = delegate;
    intersitial = [LoopMeInterstitial interstitialWithAppKey:parameters.thirdPartyAdPlacementIdentifier delegate:self];
    intersitial.autoLoadingEnabled = false;
    [intersitial loadAd];
}

- (void)showInterstitialAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters andNotify:(nonnull id<MAInterstitialAdapterDelegate>)delegate {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->intersitial.isReady)
            [self->intersitial showFromViewController:parameters.presentingViewController animated:TRUE];
       });
}

- (void)loopMeInterstitialDidLoadAd:(LoopMeInterstitial * _Nonnull)interstitial{
    [intersititalDelegate didLoadInterstitialAd];
}

- (void)loopMeInterstitial:(LoopMeInterstitial * _Nonnull)interstitial
  didFailToLoadAdWithError:(NSError * _Nonnull)error{
    [intersititalDelegate didFailToLoadInterstitialAdWithError:[MAAdapterError errorWithNSError:error]];
}

- (void)loopMeInterstitialDidAppear:(LoopMeInterstitial * _Nonnull)interstitial{
    [intersititalDelegate didDisplayInterstitialAd];
}

- (void)loopMeInterstitialDidDisappear:(LoopMeInterstitial * _Nonnull)interstitial{
    [intersititalDelegate didHideInterstitialAd];
}
@end
