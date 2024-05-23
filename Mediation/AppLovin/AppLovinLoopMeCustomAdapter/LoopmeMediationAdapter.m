 //
//  LoopmeMediationAdapter.m
//  Applovin-mediation-sample
//
//  Created by Volodymyr Novikov on 29.06.2022.
//

#import <Foundation/Foundation.h>
#import "LoopmeMediationAdapter.h"
#import "LoopMeUnitedSDK/LoopMeSDK.h"
#import "AppLovinSDK/MAInterstitialAdapterDelegate.h"
#import "AppLovinSDK/MAAdapterError.h"


@interface AppLovinMediationLoopmeRewardedAdsDelegate : NSObject<LoopMeInterstitialDelegate>
@property (nonatomic, weak) LoopmeMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(LoopmeMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate;
@end

@interface AppLovinMediationLoopmeBannerDelegate : NSObject<LoopMeAdViewDelegate>
@property (nonatomic, weak) LoopmeMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter:(LoopmeMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate;
@end

@implementation LoopmeMediationAdapter {
    LoopMeInterstitial *intersitial;
    LoopMeInterstitial *rewarded;
    LoopMeAdView *adView;
    id<MAInterstitialAdapterDelegate> intersititalDelegate;
    AppLovinMediationLoopmeRewardedAdsDelegate *rewardedAdapterDelegate;
    AppLovinMediationLoopmeBannerDelegate *bannerAdapterDelegate;
}

- (void)initializeWithParameters:(id<MAAdapterInitializationParameters>)parameters completionHandler:(void(^)(MAAdapterInitializationStatus initializationStatus, NSString *_Nullable errorMessage))completionHandler{
    [[LoopMeSDK shared] initSDKFromRootViewController:[ALUtils topViewControllerFromKeyWindow] completionBlock:^(BOOL success, NSError *error) {
         if (!success) {
             completionHandler(MAAdapterInitializationStatusInitializedFailure, @"Loopme sdk has not been initialized!");
             return;
         }
             // Set the AppLovin mediation provider
             completionHandler(MAAdapterInitializationStatusInitializedSuccess, nil);
     }];}

- (NSString *) SDKVersion{
    return [LoopMeSDK version];
}

- (NSString *)adapterVersion{
    return @"1.0.0";
}

- (void)destroy {
    intersititalDelegate = nil;
    intersitial.delegate = nil;
    intersitial = nil;
    
    rewardedAdapterDelegate.delegate = nil;
    rewardedAdapterDelegate = nil;
    rewarded.delegate = nil;
    rewarded = nil;
    
    bannerAdapterDelegate.delegate = nil;
    bannerAdapterDelegate = nil;
    adView.delegate = nil;
    adView = nil;
}


- (void)loadInterstitialAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters andNotify:(nonnull id<MAInterstitialAdapterDelegate>)delegate {
    intersititalDelegate = delegate;
    intersitial = [LoopMeInterstitial interstitialWithAppKey:parameters.thirdPartyAdPlacementIdentifier delegate:self];
    intersitial.autoLoadingEnabled = false;
    [intersitial loadAd];
}

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegat {
    bannerAdapterDelegate = [[AppLovinMediationLoopmeBannerDelegate alloc] initWithParentAdapter:self andNotify:delegat];
    NSInteger width = (NSInteger)adFormat.size.width;
    NSInteger height = (NSInteger)adFormat.size.height;
    CGRect adFrame = CGRectMake(0, 0, width, height);
    adView = [LoopMeAdView adViewWithAppKey: parameters.thirdPartyAdPlacementIdentifier
                                      frame:adFrame
                                      viewControllerForPresentationGDPRWindow:[ALUtils topViewControllerFromKeyWindow]
                                      delegate:bannerAdapterDelegate];
    adView.delegate = bannerAdapterDelegate;
    [adView loadAd];
}

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate {
    rewardedAdapterDelegate = [[AppLovinMediationLoopmeRewardedAdsDelegate alloc] initWithParentAdapter: self andNotify: delegate];

    rewarded = [LoopMeInterstitial rewardedWithAppKey:parameters.thirdPartyAdPlacementIdentifier delegate:rewardedAdapterDelegate];
    rewarded.autoLoadingEnabled = false;
    [rewarded loadAd];
}

- (void)showRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate {
    if (self->rewarded.isReady) {
        [self->rewarded showFromViewController:[ALUtils topViewControllerFromKeyWindow] animated:YES];
    }
}

- (void)showInterstitialAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters andNotify:(nonnull id<MAInterstitialAdapterDelegate>)delegate {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->intersitial.isReady)
            [self->intersitial showFromViewController:[ALUtils topViewControllerFromKeyWindow] animated:TRUE];
    });
}

//MARK: - Interstitial Delegate func
- (void)loopMeInterstitialDidLoadAd:(LoopMeInterstitial * _Nonnull)interstitial{
    [intersititalDelegate didLoadInterstitialAd];
}

- (void)loopMeInterstitial:(LoopMeInterstitial * _Nonnull)interstitial
  didFailToLoadAdWithError:(NSError * _Nonnull)error{
    [intersititalDelegate didFailToLoadInterstitialAdWithError:MAAdapterError.adNotReady];
}

- (void)loopMeInterstitialDidAppear:(LoopMeInterstitial * _Nonnull)interstitial{
    [intersititalDelegate didDisplayInterstitialAd];
}

- (void)loopMeInterstitialDidDisappear:(LoopMeInterstitial * _Nonnull)interstitial{
    [intersititalDelegate didHideInterstitialAd];
}

@end

//MARK: - AppLovinMediationLoopmeRewardedAdsDelegate
@implementation AppLovinMediationLoopmeRewardedAdsDelegate

- (instancetype)initWithParentAdapter:(LoopmeMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self ) {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)loopMeInterstitialDidLoadAd:(LoopMeInterstitial *)interstitial {
    [self.parentAdapter log: @"Rewarded ad loaded"];
    [self.delegate didLoadRewardedAd];
}

- (void)loopMeInterstitial:(LoopMeInterstitial *)interstitial didFailToLoadAdWithError:(NSError *)error {
    [self.parentAdapter log: @"Rewarded ad failed to load with error: %@", error];
    [self.delegate didFailToLoadRewardedAdWithError: MAAdapterError.adNotReady];
}

- (void)loopMeInterstitialDidAppear:(LoopMeInterstitial *)interstitial {
    [self.parentAdapter log: @"Rewarded ad did track impression"];
    [self.delegate didDisplayRewardedAd];
}

- (void)loopMeInterstitialDidReceiveTap:(LoopMeInterstitial *)interstitial {
    [self.parentAdapter log: @"Rewarded ad clicked"];
    [self.delegate didClickRewardedAd];
}

- (void)loopMeInterstitialDidDisappear:(LoopMeInterstitial *)interstitial {
    [self.parentAdapter log: @"Rewarded ad did disappear"];    
    [self.parentAdapter log: @"Rewarded ad hidden"];
    [self.delegate didHideRewardedAd];
}


- (void)loopMeInterstitialVideoDidReachEnd:(LoopMeInterstitial *)interstitial{
  [self.delegate didRewardUserWithReward:[MAReward rewardWithAmount:MAReward.defaultAmount
                                label:MAReward.defaultLabel]];
}

@end

//MARK: - AppLovinMediationLoopmeBannerDelegate
@implementation AppLovinMediationLoopmeBannerDelegate

- (instancetype)initWithParentAdapter:(LoopmeMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate {
    self = [super init];
    if ( self ) {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)loopMeAdViewDidLoadAd:(LoopMeAdView *)adView {
    [self.delegate didLoadAdForAdView: adView];
    [self.delegate didDisplayAdViewAd];
    
}
- (void)loopMeAdView:(LoopMeAdView *)adView didFailToLoadAdWithError:(NSError *)error {
    [self.parentAdapter log: @"AdView failed to load with error: %@", error];
    [self.delegate didFailToLoadAdViewAdWithError:MAAdapterError.adNotReady];
}

- (void)loopMeAdViewDidReceiveTap:(LoopMeAdView *)adView {
    [self.delegate didClickAdViewAd];
}

- (UIViewController *)viewControllerForPresentation {
    return [ALUtils topViewControllerFromKeyWindow];
}

@end
