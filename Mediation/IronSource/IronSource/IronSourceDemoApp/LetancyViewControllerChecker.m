//
//  LetancyViewControllerChecker.m
//  IronSourceDemoApp
//
//  Created by Valerii Roman on 17/07/2024.
//

#import <Foundation/Foundation.h>
#import "LetancyViewControllerChecker.h"
#import <IronSource/IronSource.h>
#import <IronSourceDemoApp-Swift.h>
#import "LetancyReportViewController.h"

@implementation LetancyViewControllerChecker {
    NSInteger loadRewardedVideoCount;
    NSInteger loadInterstitialCount;
    NSInteger loadBannerCount;
    NSInteger maxLoadAttempts;
    BOOL isInterstitial;
    BOOL isBanner;
    BOOL isRewarded;
    BOOL isLoading;
    LetancyReportViewController *letacyReportViewContrller;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    loadRewardedVideoCount = 0;
    loadInterstitialCount = 0;
    loadBannerCount = 0;
    maxLoadAttempts = 10;
    isInterstitial = NO;
    isRewarded = NO;
    isBanner = NO;
    isLoading= NO;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    letacyReportViewContrller = [storyboard instantiateViewControllerWithIdentifier:@"LetancyReportViewController"];
    
    [ISSupersonicAdsConfiguration configurations].useClientSideCallbacks = @(YES);
    
    // Before initializing any of our products (Rewarded video, Offerwall, Interstitial or Banner) you must set
    // their delegates. Take a look at each of there delegates method and you will see that they each implement a product
    // protocol. This is our way of letting you know what's going on, and if you don't set the delegates
    // we will not be able to communicate with you.
    // We're passing 'self' to our delegates because we want
    // to be able to enable/disable buttons to match ad availability.
    
    [IronSource setLevelPlayRewardedVideoManualDelegate: self];
    [IronSource setLevelPlayInterstitialDelegate: self];
    [IronSource setLevelPlayBannerDelegate: self];
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.activityIndicator.center = self.view.center;
    [self.view addSubview:self.activityIndicator];
}

- (void)showActivityIndicator {
    [self.activityIndicator startAnimating];
    self.activityIndicator.hidden = NO;
}

- (void)hideActivityIndicator {
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
}

- (IBAction)checkRewarded:(UIButton *)sender {
    if (isLoading == NO) {
        [self loadRewardedVideo];
    }
}

- (IBAction)checkInterstitial:(UIButton *)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isLoading == NO) {
            [self loadInterstitialVideo];
        }
    });
}

- (IBAction)checkBanner:(UIButton *)sender {
    if (isLoading == NO) {
        [self loadBanner];
    }
}

- (void)loadRewardedVideo {
    if (loadRewardedVideoCount == 0) {
        [self showActivityIndicator];
    }
    
    if (loadRewardedVideoCount < maxLoadAttempts) {
        isLoading = YES;
        isRewarded = YES;
        loadRewardedVideoCount++;
        [[LegacyManger shared] logEventForCall: @(loadRewardedVideoCount) withText:@"Load (App)" adType:@"Rewarded"];
        [IronSource loadRewardedVideo];
        NSLog(@"Rewarded video load attempt: %ld", (long)loadRewardedVideoCount);
    } else {
        isLoading = NO;
        isRewarded = NO;
        [self hideActivityIndicator];
        loadRewardedVideoCount = 0;
        NSLog(@"%@", [[LegacyManger shared] getLogDictionary]);
        [self showViewController:letacyReportViewContrller sender:self];
    }
}

- (void)loadInterstitialVideo {
    if (loadInterstitialCount == 0) {
        [self showActivityIndicator];
    }
    
    if (loadInterstitialCount < maxLoadAttempts) {
        isLoading = YES;
        isInterstitial = YES;
        [[LegacyManger shared] logEventForCall: @(loadInterstitialCount) withText:@"Load (App)" adType: @"Interstitial"];
        [IronSource loadInterstitial];
        loadInterstitialCount++;
        NSLog(@"Interstitial video load attempt: %ld", (long)loadInterstitialCount);
    } else {
        isLoading = NO;
        isInterstitial = NO;
        [self hideActivityIndicator];
        loadInterstitialCount = 0;
        NSLog(@"%@", [[LegacyManger shared] getLogDictionary]);
        [self showViewController:letacyReportViewContrller sender:self];
    }
}

- (void)loadBanner {
    if (loadBannerCount == 0) {
        [self showActivityIndicator];
    }

    
    if (loadBannerCount < maxLoadAttempts) {
        isLoading = YES;
        isBanner = YES;
        [[LegacyManger shared] logEventForCall: @(loadBannerCount) withText:@"Load (App)" adType: @"Banner"];
        [IronSource loadBannerWithViewController: self size: ISBannerSize_BANNER];
        loadBannerCount++;
        NSLog(@"Banner video load attempt: %ld", (long)loadBannerCount);
    } else {
        isLoading = NO;
        isBanner = NO;
        [self hideActivityIndicator];
        loadBannerCount = 0;
        NSLog(@"%@", [[LegacyManger shared] getLogDictionary]);
        [self showViewController:letacyReportViewContrller sender:self];
    }
}

- (void)didLoadWithAdInfo: (ISAdInfo *)adInfo{
    
    if (isInterstitial == YES ) {
        [[LegacyManger shared] logEventForCall: nil withText:@"Did Load (App)" adType: @"Interstitial"];
        [self loadInterstitialVideo];
    }
    
    if (isRewarded == YES ) {
        [[LegacyManger shared] logEventForCall: nil withText:@"Did Load (App)" adType: @"Rewarded"];
        [self loadRewardedVideo];
    }
}

- (void)didFailToLoadWithError: (NSError *)error {
    NSLog(@"didFailToLoadWithError: %@", error);
    if (isBanner == YES ) {
        [[LegacyManger shared] logEventForCall: nil withText:@"Did Fail (App)" adType: @"Banner"];
        [self loadBanner];
    }
    
    if (isInterstitial == YES ) {
        [[LegacyManger shared] logEventForCall: nil withText:@"Did Fail (App)" adType:@"Interstitial"];
        [self loadInterstitialVideo];
    }
    if (isRewarded == YES ) {
        [[LegacyManger shared] logEventForCall: nil withText:@"Did Fail (App)" adType: @"Rewarded"];
        [self loadRewardedVideo];
    }
    
}

- (void)didReceiveRewardForPlacement: (ISPlacementInfo *)placementInfo withAdInfo: (ISAdInfo *)adInfo { }

- (void)didFailToShowWithError: (NSError *)error andAdInfo: (ISAdInfo *)adInfo { }

- (void)didOpenWithAdInfo: (ISAdInfo *)adInfo { }

- (void)didCloseWithAdInfo: (ISAdInfo *)adInfo { }

- (void)didClick: (ISPlacementInfo *)placementInfo withAdInfo: (ISAdInfo *)adInfo { }

- (void)didClickWithAdInfo: (ISAdInfo *)adInfo { }

- (void)didLoad: (ISBannerView *)bannerView withAdInfo: (ISAdInfo *)adInfo {
    [[LegacyManger shared] logEventForCall: nil withText:@"Did Load (App)" adType: @"Banner"];
    
    [IronSource destroyBanner: bannerView];
    [self loadBanner];
}

- (void)didDismissScreenWithAdInfo: (ISAdInfo *)adInfo { }

- (void)didLeaveApplicationWithAdInfo: (ISAdInfo *)adInfo { }

- (void)didPresentScreenWithAdInfo: (ISAdInfo *)adInfo { }

- (void)didShowWithAdInfo: (ISAdInfo *)adInfo { }

@end
