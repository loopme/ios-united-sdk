//
//  GADMAdapterLoopMeBanner.m
//  AdMob
//
//  Created by Valerii Roman on 21/05/2024.
//

#import <Foundation/Foundation.h>
#import <LoopMeUnitedSDK/LoopMeSDK.h>
#import <LoopMeUnitedSDK/LoopMeInterstitial.h>
#import <GoogleMobileAds/GoogleMobileAds.h>


@interface GADMAdapterLoopMeBanner : NSObject <LoopMeAdViewDelegate, GADMediationInterstitialAdEventDelegate>

@property (nonatomic, strong) LoopMeAdView *banner;
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, strong) id<GADMediationBannerAdEventDelegate> delegate;

@end


@implementation GADMAdapterLoopMeBanner



- (void)didDismissFullScreenView { 
    <#code#>
}

- (void)didFailToPresentWithError:(nonnull NSError *)error { 
    <#code#>
}

- (void)reportClick { 
    <#code#>
}

- (void)reportImpression { 
    <#code#>
}

- (void)willDismissFullScreenView { 
    <#code#>
}

- (void)willPresentFullScreenView { 
    <#code#>
}

- (UIViewController *)viewControllerForPresentation { 
    return  self.viewController;
}

@end
