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
    UIViewController *viewController;
    id<MAInterstitialAdapterDelegate> intersititalDelegate;
    AppLovinMediationLoopmeRewardedAdsDelegate *rewardedAdapterDelegate;
    AppLovinMediationLoopmeBannerDelegate *bannerAdapterDelegate;
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

- (void)destroy {
    intersititalDelegate = nil;
    bannerAdapterDelegate = nil;
    rewardedAdapterDelegate = nil;
    intersitial.delegate = nil;
    rewarded.delegate = nil;
    adView.delegate = nil;
}


- (void)loadInterstitialAdForParameters:(nonnull id<MAAdapterResponseParameters>)parameters andNotify:(nonnull id<MAInterstitialAdapterDelegate>)delegate {
    intersititalDelegate = delegate;
    intersitial = [LoopMeInterstitial interstitialWithAppKey:parameters.thirdPartyAdPlacementIdentifier delegate:self];
    viewController = parameters.presentingViewController;
    intersitial.autoLoadingEnabled = false;
    [intersitial loadAd];
}

- (void)loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters adFormat:(MAAdFormat *)adFormat andNotify:(id<MAAdViewAdapterDelegate>)delegat {
    bannerAdapterDelegate = [[AppLovinMediationLoopmeBannerDelegate alloc] initWithParentAdapter:self andNotify:delegat];
    CGRect adFrame = CGRectMake(0, 0, 250, 50);
    viewController = parameters.presentingViewController;
    adView = [LoopMeAdView adViewWithAppKey:parameters.thirdPartyAdPlacementIdentifier frame:adFrame viewControllerForPresentationGDPRWindow:parameters.presentingViewController delegate:bannerAdapterDelegate];
    [adView loadAd];
}

- (void)loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters andNotify:(id<MARewardedAdapterDelegate>)delegate {
    rewardedAdapterDelegate = [[AppLovinMediationLoopmeRewardedAdsDelegate alloc] initWithParentAdapter: self andNotify: delegate];
    viewController = parameters.presentingViewController;
    rewarded = [LoopMeInterstitial interstitialWithAppKey:parameters.thirdPartyAdPlacementIdentifier delegate:rewardedAdapterDelegate];
    viewController = parameters.presentingViewController;
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
            [self->intersitial showFromViewController:parameters.presentingViewController animated:TRUE];
    });
}

//MARK: - Interstitial Delegate func
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

//MARK: - AppLovinMediationLoopmeRewardedAdsDelegate
@implementation AppLovinMediationLoopmeRewardedAdsDelegate

- (instancetype)initWithParentAdapter:(LoopmeMediationAdapter *)parentAdapter andNotify:(id<MARewardedAdapterDelegate>)delegate
{
    self = [super init];
    if ( self )
    {
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
    [self.delegate didFailToLoadRewardedAdWithError: error];
}

- (void)loopMeInterstitialDidAppear:(LoopMeInterstitial *)interstitial {
    [self.parentAdapter log: @"Rewarded ad did track impression"];
    [self.delegate didDisplayRewardedAd];
    [self.delegate didStartRewardedAdVideo];
}

- (void)loopMeInterstitialDidReceiveTap:(LoopMeInterstitial *)interstitial {
    [self.parentAdapter log: @"Rewarded ad clicked"];
    [self.delegate didClickRewardedAd];
}

- (void)loopMeInterstitialDidDisappear:(LoopMeInterstitial *)interstitial {
    [self.parentAdapter log: @"Rewarded ad did disappear"];
    [self.delegate didCompleteRewardedAdVideo];
    
    [self.parentAdapter log: @"Rewarded ad hidden"];
    [self.delegate didHideRewardedAd];
}

@end

//MARK: - AppLovinMediationLoopmeBannerDelegate
@implementation AppLovinMediationLoopmeBannerDelegate

- (instancetype)initWithParentAdapter:(LoopmeMediationAdapter *)parentAdapter andNotify:(id<MAAdViewAdapterDelegate>)delegate {
    self = [super init];
    if ( self )
    {
        self.parentAdapter = parentAdapter;
        self.delegate = delegate;
    }
    return self;
}

- (void)loopMeAdViewDidLoadAd:(LoopMeAdView *)adView {
    [self.delegate didLoadAdForAdView: adView];
    
}
- (void)loopMeAdView:(LoopMeAdView *)adView didFailToLoadAdWithError:(NSError *)error {
    [self.delegate didFailToLoadAdViewAdWithError:error];
}

- (void)loopMeAdViewDidReceiveTap:(LoopMeAdView *)adView {
    [self.delegate didClickAdViewAd];
}

- (UIViewController *)viewControllerForPresentation {
    return [ALUtils topViewControllerFromKeyWindow];
}


@end
