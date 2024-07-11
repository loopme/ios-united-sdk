//
//  ISLoopMeCustomBanner.m
//  IronSourceDemoApp
//
//  Created by ValeriiRoman on 29/09/2023.
//  Copyright © 2023 supersonic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISLoopmeCustomBanner.h"

@implementation ISLoopmeCustomBanner

- (void)loadAdWithAdData: (nonnull ISAdData *)adData
          viewController: (UIViewController *)viewController
                    size: (ISBannerSize *)size
                delegate: (nonnull id<ISBannerAdDelegate>)delegate {
    self.viewController = viewController;
    NSString *appkey = adData.configuration[@"instancekey"];
    NSLog(@"loopme's appkey - %@", appkey);
    
    CGRect adFrame = CGRectMake(0, 0, size.width, size.height);
    dispatch_async(dispatch_get_main_queue(), ^{
        LoopMeAdView *bannerView = [LoopMeAdView adViewWithAppKey: appkey frame: adFrame delegate: self];
        self.banner = bannerView;
        self.banner.delegate = self;
    
        self.delegate = delegate;
        [self.banner loadAd];
    });
}

- (BOOL)isSupportAdaptiveBanner {
    return YES;
}

- (void)loopMeAdViewDidLoadAd: (LoopMeAdView *)banner {
    NSLog(@"LoopMe banner did load");
    [self.delegate adDidLoadWithView: self.banner];
}

- (void)loopMeAdView: (LoopMeAdView *)adView didFailToLoadAdWithError: (NSError *)error {
    NSLog(@"LoopMe banner did fail with error: %@", [error localizedDescription]);
    [self.delegate adDidFailToLoadWithErrorType: ISAdapterErrorTypeNoFill
                                      errorCode: ISAdapterErrorInternal
                                   errorMessage: [error localizedDescription]];
    
}

- (void)loopMeAdViewDidAppear: (LoopMeAdView *)banner {
    NSLog(@"LoopMe banner did present");
    [self.delegate adDidOpen];
}

- (void)loopMeAdViewDidDisappear:(LoopMeAdView *)banner {
    NSLog(@"LoopMe banner did dismiss");
    [self.delegate adDidDismissScreen];
}

- (void)loopMeAdViewDidReceiveTap:(LoopMeAdView *)banner {
    NSLog(@"LoopMe banner was tapped.");
    [self.delegate adDidClick];
}

- (void)destroyAdWithAdData: (ISAdData *)adData {
    [self.delegate adDidDismissScreen];
}

- (UIViewController *)viewControllerForPresentation {
    return self.viewController;
}

@end
