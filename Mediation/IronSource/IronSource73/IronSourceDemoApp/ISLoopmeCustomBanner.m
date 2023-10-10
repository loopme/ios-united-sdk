//
//  ISLoopMeCustomBanner.m
//  IronSourceDemoApp
//
//  Created by ValeriiRoman on 29/09/2023.
//  Copyright © 2023 supersonic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISLoopmeCustomBanner.h"
#import "LoopMeUnitedSDK/LoopMeAdView.h"

@interface ISLoopmeCustomBanner()<LoopMeAdViewDelegate>

@property (nonatomic, strong) LoopMeAdView *banner;
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, strong) id<ISBannerAdDelegate> delegate;
@end


@implementation ISLoopmeCustomBanner

- (void)loadAdWithAdData:(nonnull ISAdData *)adData
          viewController:(UIViewController *)viewController
                    size:(ISBannerSize *)size
                delegate:(nonnull id<ISBannerAdDelegate>)delegate {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    NSString *appkey = nil;
    self.viewController = viewController;
    
    if (standardUserDefaults) {
        appkey = [standardUserDefaults objectForKey:@"LOOPME_BANNER"];
        NSLog(@"loopme's appkey - %@", appkey);
        CGRect adFrame = CGRectMake(0, 0, size.width, size.height);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            LoopMeAdView *bannerView = [LoopMeAdView adViewWithAppKey:appkey
                                                                frame:adFrame
                              viewControllerForPresentationGDPRWindow:viewController
                                                             delegate:self];
            self.banner = bannerView;
            self.banner.delegate = self;
        });
        self.delegate = delegate;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.banner loadAd];
        });
    }
}

- (BOOL)isSupportAdaptiveBanner {
    return YES;
}

- (BOOL)isAdAvailableWithAdData:(nonnull ISAdData *)adData {
    return [self.banner isReady];
}

- (void)showAdWithViewController:(nonnull UIViewController *)viewController
                          adData:(nonnull ISAdData *)adData
                        delegate:(nonnull id<ISInterstitialAdDelegate>)delegate {
    // check if ad can be displayed
    if (![self.banner isReady]) {
        [delegate adDidFailToShowWithErrorCode:ISAdapterErrorInternal
                                  errorMessage:nil];
        return;
    }
    [delegate adDidShowSucceed];
}

- (void)loopMeAdViewDidLoadAd:(LoopMeAdView *)banner {
    NSLog(@"LoopMe banner did load");
    [self.delegate adDidLoadWithView: self.banner];
}

- (void)loopMeAdView:(LoopMeAdView *)banner didFailToLoadAdWithError:(NSError *)error {
    NSLog(@"LoopMe interstitial did fail with error: %@", [error localizedDescription]);
    [self.delegate adDidFailToLoadWithErrorType:ISAdapterErrorTypeInternal
                                      errorCode:[error code] errorMessage:nil];
}

- (void)loopMeAdViewDidAppear:(LoopMeAdView *)banner {
    NSLog(@"LoopMe interstitial did present");
    [self.delegate adDidOpen];
}

- (void)loopMeAdViewDidDisappear:(LoopMeAdView *)banner {
    NSLog(@"LoopMe interstitial did dismiss");
    [self.delegate adDidDismissScreen];
}

- (void)loopMeAdViewDidReceiveTap:(LoopMeAdView *)banner {
    NSLog(@"LoopMe interstitial was tapped.");
    [self.delegate adDidClick];
}

- (void)loopMeAdViewVideoDidReachEnd:(LoopMeAdView *)banner {
    NSLog(@"LoopMe interstitial video did reach end.");
}

- (void)destroyAdWithAdData:(ISAdData *)adData {
    [self.delegate adDidDismissScreen];
}

- (UIViewController *)viewControllerForPresentation {
    return self.viewController;
}

@end
