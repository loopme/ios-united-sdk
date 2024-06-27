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

@interface AppLovinMediationLoopmeInterstitialAdsDelegate : NSObject<LoopMeInterstitialDelegate>
@property (nonatomic, weak) LoopmeMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAInterstitialAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter: (LoopmeMediationAdapter *)parentAdapter
                            andNotify: (id<MAInterstitialAdapterDelegate>)delegate;
@end

@interface AppLovinMediationLoopmeRewardedAdsDelegate : NSObject<LoopMeInterstitialDelegate>
@property (nonatomic, weak) LoopmeMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MARewardedAdapterDelegate> delegate;
@property (nonatomic, assign) BOOL hasRewarded;
- (instancetype)initWithParentAdapter: (LoopmeMediationAdapter *)parentAdapter
                            andNotify: (id<MARewardedAdapterDelegate>)delegate;
@end

@interface AppLovinMediationLoopmeBannerDelegate : NSObject<LoopMeAdViewDelegate>
@property (nonatomic, weak) LoopmeMediationAdapter *parentAdapter;
@property (nonatomic, strong) id<MAAdViewAdapterDelegate> delegate;
- (instancetype)initWithParentAdapter: (LoopmeMediationAdapter *)parentAdapter
                            andNotify: (id<MAAdViewAdapterDelegate>)delegate;
@end

@implementation LoopmeMediationAdapter {
    LoopMeInterstitial *intersitial;
    LoopMeInterstitial *rewarded;
    LoopMeAdView *adView;
    AppLovinMediationLoopmeInterstitialAdsDelegate *interstitialAdapterDelegate;
    AppLovinMediationLoopmeRewardedAdsDelegate *rewardedAdapterDelegate;
    AppLovinMediationLoopmeBannerDelegate *bannerAdapterDelegate;
}

- (void)initializeWithParameters: (id<MAAdapterInitializationParameters>)parameters
               completionHandler: (void(^)(MAAdapterInitializationStatus initializationStatus, NSString *_Nullable errorMessage))completionHandler {
    // TODO: Replace deprecated initSDKFromRootViewController with init
    [[LoopMeSDK shared] init: ^(BOOL success, NSError *error) {
        if (!success) {
            completionHandler(MAAdapterInitializationStatusInitializedFailure, @"Loopme sdk has not been initialized!");
            return;
        }
        // Set the AppLovin mediation provider
        completionHandler(MAAdapterInitializationStatusInitializedSuccess, nil);
    }];
}

- (NSString *) SDKVersion{
    return [LoopMeSDK version];
}

- (NSString *)adapterVersion{
    return @"0.0.7";
}

- (void)destroy {
    interstitialAdapterDelegate.delegate = nil;
    interstitialAdapterDelegate = nil;
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

- (void)loadInterstitialAdForParameters: (nonnull id<MAAdapterResponseParameters>)parameters
                              andNotify: (nonnull id<MAInterstitialAdapterDelegate>)delegate {
    interstitialAdapterDelegate = [[AppLovinMediationLoopmeInterstitialAdsDelegate alloc] initWithParentAdapter: self
                                                                                                      andNotify: delegate];
    intersitial = [LoopMeInterstitial interstitialWithAppKey: parameters.thirdPartyAdPlacementIdentifier
                                                    delegate: interstitialAdapterDelegate];
    intersitial.autoLoadingEnabled = NO;
    [intersitial loadAd];
}

- (void)loadRewardedAdForParameters: (id<MAAdapterResponseParameters>)parameters
                          andNotify: (id<MARewardedAdapterDelegate>)delegate {
    rewardedAdapterDelegate = [[AppLovinMediationLoopmeRewardedAdsDelegate alloc] initWithParentAdapter: self
                                                                                              andNotify: delegate];
    rewarded = [LoopMeInterstitial rewardedWithAppKey: parameters.thirdPartyAdPlacementIdentifier
                                             delegate: rewardedAdapterDelegate];
    rewarded.autoLoadingEnabled = NO;
    [rewarded loadAd];
}

- (void)loadAdViewAdForParameters: (id<MAAdapterResponseParameters>)parameters
                         adFormat: (MAAdFormat *)adFormat
                        andNotify: (id<MAAdViewAdapterDelegate>)delegate {
    bannerAdapterDelegate = [[AppLovinMediationLoopmeBannerDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    adView = [LoopMeAdView adViewWithAppKey: parameters.thirdPartyAdPlacementIdentifier
                                      frame: CGRectMake(0, 0, (NSInteger)adFormat.size.width, (NSInteger)adFormat.size.height)
    viewControllerForPresentationGDPRWindow: [ALUtils topViewControllerFromKeyWindow]
                                   delegate: bannerAdapterDelegate];
    adView.delegate = bannerAdapterDelegate;
    [adView loadAd];
}

- (void)showRewardedAdForParameters: (id<MAAdapterResponseParameters>)parameters
                          andNotify: (id<MARewardedAdapterDelegate>)delegate {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->rewarded.isReady) {
            [self->rewarded showFromViewController: [ALUtils topViewControllerFromKeyWindow]
                                          animated: YES];
        }
    });
}

- (void)showInterstitialAdForParameters: (nonnull id<MAAdapterResponseParameters>)parameters
                              andNotify: (nonnull id<MAInterstitialAdapterDelegate>)delegate {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->intersitial.isReady)
            [self->intersitial showFromViewController: [ALUtils topViewControllerFromKeyWindow]
                                             animated: YES];
    });
}

@end

//MARK: - AppLovinMediationLoopmeRewardedAdsDelegate
@implementation AppLovinMediationLoopmeInterstitialAdsDelegate

- (instancetype)initWithParentAdapter: (LoopmeMediationAdapter *)parentAdapter
                            andNotify: (id<MAInterstitialAdapterDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)loopMeInterstitialDidLoadAd: (LoopMeInterstitial *)interstitial {
    [self.parentAdapter log: @"Interstitial ad loaded"];
    [self.delegate didLoadInterstitialAd];
}

- (void)loopMeInterstitial: (LoopMeInterstitial *)interstitial
  didFailToLoadAdWithError: (NSError *)error {
    [self.parentAdapter log: @"Interstitial ad failed to load with error: %@", error];
    [self.delegate didFailToLoadInterstitialAdWithError: MAAdapterError.adNotReady];
}

- (void)loopMeInterstitialDidAppear: (LoopMeInterstitial *)interstitial {
    [self.parentAdapter log: @"Interstitial ad did track impression"];
    [self.delegate didDisplayInterstitialAd];
}

- (void)loopMeInterstitialDidReceiveTap: (LoopMeInterstitial *)interstitial {
    [self.parentAdapter log: @"Interstitial ad clicked"];
    [self.delegate didClickInterstitialAd];
}

- (void)loopMeInterstitialDidDisappear: (LoopMeInterstitial *)interstitial {
    [self.parentAdapter log: @"Interstitial ad did disappear"];
    [self.delegate didHideInterstitialAd];
}

@end

//MARK: - AppLovinMediationLoopmeRewardedAdsDelegate
@implementation AppLovinMediationLoopmeRewardedAdsDelegate

- (instancetype)initWithParentAdapter: (LoopmeMediationAdapter *)parentAdapter
                            andNotify: (id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
        self.hasRewarded = false;
    }
    return self;
}

- (void)loopMeInterstitialDidLoadAd: (LoopMeInterstitial *)interstitial {
    [self.parentAdapter log: @"Rewarded ad loaded"];
    [self.delegate didLoadRewardedAd];
}

- (void)loopMeInterstitial: (LoopMeInterstitial *)interstitial
  didFailToLoadAdWithError: (NSError *)error {
    [self.parentAdapter log: @"Rewarded ad failed to load with error: %@", error];
    [self.delegate didFailToLoadRewardedAdWithError: MAAdapterError.adNotReady];
}

- (void)loopMeInterstitialDidAppear: (LoopMeInterstitial *)interstitial {
    [self.parentAdapter log: @"Rewarded ad did track impression"];
    [self.delegate didDisplayRewardedAd];
}

- (void)loopMeInterstitialDidReceiveTap: (LoopMeInterstitial *)interstitial {
    [self.parentAdapter log: @"Rewarded ad clicked"];
    [self.delegate didClickRewardedAd];
}

- (void)loopMeInterstitialDidDisappear: (LoopMeInterstitial *)interstitial {
    if (self.hasRewarded) {
        [self.delegate didHideRewardedAd];
        [self.parentAdapter log: @"Rewarded ad did disappear"];
    } else {
        [self.delegate didRewardUserWithReward: [MAReward rewardWithAmount: MAReward.defaultAmount
                                                                     label: MAReward.defaultLabel]];
    }
}


- (void)loopMeInterstitialVideoDidReachEnd: (LoopMeInterstitial *)interstitial {
    self.hasRewarded = true;
  [self.delegate didRewardUserWithReward: [MAReward rewardWithAmount: MAReward.defaultAmount
                                                               label: MAReward.defaultLabel]];
}

@end

//MARK: - AppLovinMediationLoopmeBannerDelegate
@implementation AppLovinMediationLoopmeBannerDelegate

- (instancetype)initWithParentAdapter: (LoopmeMediationAdapter *)parentAdapter
                            andNotify: (id<MAAdViewAdapterDelegate>)delegate {
    self = [super init];
    if (self) {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)loopMeAdViewDidLoadAd: (LoopMeAdView *)adView {
    [self.delegate didLoadAdForAdView: adView];
    [self.delegate didDisplayAdViewAd];
    
}
- (void)loopMeAdView: (LoopMeAdView *)adView didFailToLoadAdWithError: (NSError *)error {
    [self.parentAdapter log: @"AdView failed to load with error: %@", error];
    [self.delegate didFailToLoadAdViewAdWithError: MAAdapterError.adNotReady];
}

- (void)loopMeAdViewDidReceiveTap: (LoopMeAdView *)adView {
    [self.delegate didClickAdViewAd];
}

- (UIViewController *)viewControllerForPresentation {
    return [ALUtils topViewControllerFromKeyWindow];
}

@end
