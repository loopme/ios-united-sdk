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
@end


@implementation ISLoopmeCustomRewardedVideo

- (void)loadAdWithAdData:(nonnull ISAdData *)adData
                delegate:(nonnull id<ISRewardedVideoAdDelegate>)delegate {
    
    NSString *appkey = adData.configuration[@"instancekey"];
    NSLog(@"Rewarded appkey %@", appkey);
    
    self.interstitial = [LoopMeInterstitial interstitialWithAppKey:appkey delegate:self];
    [self.interstitial setAutoLoadingEnabled:FALSE];

    self.delegate = delegate;
    [self.interstitial loadAd];
}

- (BOOL)isAdAvailableWithAdData:(nonnull ISAdData *)adData {
    return [self.interstitial isReady];
}

- (void)showAdWithViewController:(nonnull UIViewController *)viewController
                          adData:(nonnull ISAdData *)adData
                        delegate:(nonnull id<ISRewardedVideoAdDelegate>)delegate {
    // check if ad can be displayed
    if (![self.interstitial isReady]) {
       [delegate adDidFailToShowWithErrorCode:ISAdapterErrorInternal
                                  errorMessage:nil];
       return;
    }
     [self.interstitial showFromViewController:viewController animated:YES];
     [delegate adDidShowSucceed];
}

- (void)loopMeInterstitialDidLoadAd:(LoopMeInterstitial *)interstitial {
    NSLog(@"LoopMe rewarded did load");
    [self.delegate adDidLoad];
}

- (void)loopMeInterstitial:(LoopMeInterstitial *)interstitial didFailToLoadAdWithError:(NSError *)error {
    NSLog(@"LoopMe rewarded did fail with error: %@", [error localizedDescription]);
    [self.delegate adDidFailToLoadWithErrorType:ISAdapterErrorTypeInternal
     errorCode:[error code] errorMessage:nil];
}

- (void)loopMeInterstitialDidAppear:(LoopMeInterstitial *)interstitial {
    NSLog(@"LoopMe rewarded did present");
    [self.delegate adDidOpen];
}

- (void)loopMeInterstitialDidDisappear:(LoopMeInterstitial *)interstitial {
    NSLog(@"LoopMe rewarded did dismiss");
    [self.delegate adDidClose];
}

- (void)loopMeInterstitialDidReceiveTap:(LoopMeInterstitial *)interstitial {
    NSLog(@"LoopMe rewarded was tapped.");
    [self.delegate adDidClick];
}

- (void)loopMeInterstitialVideoDidReachEnd:(LoopMeInterstitial *)interstitial {
    NSLog(@"LoopMe rewarded video did reach end.");
    [self.delegate adRewarded];
}

@end