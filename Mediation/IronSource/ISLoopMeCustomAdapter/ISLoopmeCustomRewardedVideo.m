//
//  ISLoopmeCustomRewardedVideo.m
//  IronSourceDemoApp
//
//  Created by Volodymyr Novikov on 05.01.2023.
//  Copyright © 2023 supersonic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISLoopmeCustomRewardedVideo.h"
#import "LoopMeUnitedSDK/LoopMeInterstitial.h"

@interface ISLoopmeCustomRewardedVideo()<LoopMeInterstitialDelegate>
@property (nonatomic, strong) LoopMeInterstitial *interstitial;
@property (nonatomic, strong) id<ISRewardedVideoAdDelegate> delegate;
@property (nonatomic, assign) BOOL hasRewarded;

@end

@implementation ISLoopmeCustomRewardedVideo

- (void)loadAdWithAdData: (nonnull ISAdData *)adData
                delegate: (nonnull id<ISRewardedVideoAdDelegate>)delegate {
    NSString *appkey = adData.configuration[@"instancekey"];
    NSLog(@"loopme's appkey - %@", appkey);
    
    self.interstitial = [LoopMeInterstitial rewardedWithAppKey: appkey delegate: self];
    [self.interstitial setAutoLoadingEnabled: NO];

    self.delegate = delegate;
    self.hasRewarded = NO;
    [self.interstitial loadAd];
}

- (BOOL)isAdAvailableWithAdData: (nonnull ISAdData *)adData {
    return [self.interstitial isReady];
}

- (void)showAdWithViewController: (nonnull UIViewController *)viewController
                          adData: (nonnull ISAdData *)adData
                        delegate: (nonnull id<ISRewardedVideoAdDelegate>)delegate {
    // check if ad can be displayed
    if (![self.interstitial isReady]) {
       [delegate adDidFailToShowWithErrorCode: ISAdapterErrorInternal errorMessage: nil];
       return;
    }
     [self.interstitial showFromViewController: viewController animated: YES];
     [delegate adDidShowSucceed];
}

- (void)loopMeInterstitialDidLoadAd: (LoopMeInterstitial *)interstitial {
    NSLog(@"LoopMe rewarded video did load");
    [self.delegate adDidLoad];
}

- (void)loopMeInterstitial: (LoopMeInterstitial *)interstitial didFailToLoadAdWithError: (NSError *)error {
    NSLog(@"LoopMe rewarded video did fail with error: %@", [error localizedDescription]);
    [self.delegate adDidFailToLoadWithErrorType: ISAdapterErrorTypeInternal
                                      errorCode: [error code]
                                   errorMessage: nil];
}

- (void)loopMeInterstitialDidAppear: (LoopMeInterstitial *)interstitial {
    NSLog(@"LoopMe rewarded video did present");
    [self.delegate adDidOpen];
}

- (void)loopMeInterstitialDidDisappear: (LoopMeInterstitial *)interstitial {
    if (!self.hasRewarded) {
        [self.delegate adRewarded];
        NSLog(@"LoopMe rewarded video did reach end.");
    }
    [self.delegate adDidClose];
    NSLog(@"LoopMe rewarded video did dismiss");
}

- (void)loopMeInterstitialDidReceiveTap: (LoopMeInterstitial *)interstitial {
    NSLog(@"LoopMe rewarded video was tapped.");
    [self.delegate adDidClick];
}

- (void)loopMeInterstitialVideoDidReachEnd: (LoopMeInterstitial *)interstitial {
    NSLog(@"LoopMe rewarded video did reach end.");
    self.hasRewarded = YES;
    [self.delegate adRewarded];
}

@end
