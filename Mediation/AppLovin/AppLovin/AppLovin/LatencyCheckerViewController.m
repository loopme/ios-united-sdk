//
//  LatencyCheckerViewController.m
//  AppLovinDemoApp
//
//  Created by Valerii Roman on 25/07/2024.
//

#import "LatencyCheckerViewController.h"
#import "LatencyManagerSwizz.h"

@interface LatencyCheckerViewController ()


@property (nonatomic, strong) MAAdView *adView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) MARewardedAd *rewarded;
@property (nonatomic, strong) MAInterstitialAd *interstitialAd;

@end
//private let adUnitIdentifier = "1fc903a950c51d3e"
@implementation LatencyCheckerViewController {
    NSInteger loadInterstitialCount;
    NSInteger loadRewardedVideoCount;
    NSInteger loadBannerCount;
    NSInteger maxLoadAttempts;
    BOOL isInterstitial;
    BOOL isBanner;
    BOOL isRewarded;
    BOOL isLoading;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    maxLoadAttempts = 10;
    loadRewardedVideoCount = 0;
    loadInterstitialCount = 0;
    loadBannerCount = 0;
    isInterstitial = NO;
    isBanner = NO;
    isRewarded = NO;
    isLoading = NO;

    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.activityIndicator.center = self.view.center;
    self.activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.activityIndicator];
    
    self.adView = [[MAAdView alloc] initWithAdUnitIdentifier:@"1ef882e49e5d9430"];
    self.adView.delegate = self;
    
    self.rewarded = [MARewardedAd sharedWithAdUnitIdentifier: @"dfd4fcbe11acafdf"];
    self.rewarded.delegate = self;
    
    self.interstitialAd = [[MAInterstitialAd alloc] initWithAdUnitIdentifier:@"1fc903a950c51d3e"];
    self.interstitialAd.delegate = self;
    
}

- (IBAction)checkRewarded:(UIButton *)sender {
    if (!isLoading) {
        [self loadRewardedVideo];
    }
}

- (IBAction)checkInterstitial:(UIButton *)sender {
    if (!isLoading) {
        [self loadInterstitialVideo];
    }
}

- (IBAction)checkBanner:(UIButton *)sender {
    if (!isLoading) {
        [self loadBanner];
    }
}

- (void)showActivityIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator startAnimating];
        self.activityIndicator.hidden = NO;
    });
}

- (void)hideActivityIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator stopAnimating];
        self.activityIndicator.hidden = YES;
    });
}

- (void)loadBanner {
    if (loadBannerCount == 0) {
        [self showActivityIndicator];
    }
    
    if (loadBannerCount < maxLoadAttempts) {
        isLoading = YES;
        isBanner = YES;
        loadBannerCount++;
        [[LegacyManger shared] logEventForCall:@(loadBannerCount) withText:@"Load (App)" adType:@"Banner"];
        [self.adView loadAd];
    } else {
        [self hideActivityIndicator];
        [self.adView stopAutoRefresh];
        isLoading = NO;
        isBanner = NO;
        loadBannerCount = 0;
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
        [[LegacyManger shared] logEventForCall:@(loadRewardedVideoCount) withText:@"Load Rewarded (App)" adType:@"Rewarded"];
        [self.rewarded loadAd];
    } else {
        [self hideActivityIndicator];
        isLoading = NO;
        isRewarded = NO;
        loadRewardedVideoCount = 0;
    }
}

- (void)loadInterstitialVideo {
    if (loadInterstitialCount == 0) {
        [self showActivityIndicator];
    }
    
    if (loadInterstitialCount < maxLoadAttempts) {
        isLoading = YES;
        isInterstitial = YES;
        loadInterstitialCount++;
        [[LegacyManger shared] logEventForCall:@(loadInterstitialCount) withText:@"Load (App)" adType:@"Interstitial"];
        [self.interstitialAd loadAd];
    } else {
        [self hideActivityIndicator];
        isLoading = NO;
        isInterstitial = NO;
        loadInterstitialCount = 0;
    }
}


- (void)didLoadAd:(MAAd *)ad {
    if (isRewarded == YES) {
        [[LegacyManger shared] logEventForCall:@(loadRewardedVideoCount) withText:@"Did Load (App)" adType:@"Rewarded"];
        [self loadRewardedVideo];
    }
    if (isBanner == YES) {
        [[LegacyManger shared] logEventForCall:@(loadBannerCount) withText:@"Did Load (App)" adType:@"Banner"];
        
        [self loadBanner];
    }
    if (isInterstitial == YES) {
        [[LegacyManger shared] logEventForCall:@(loadInterstitialCount) withText:@"Did Load (App)" adType:@"Interstitial"];
        _interstitialAd = nil;
        [self loadInterstitialVideo];
    }
}

- (void)didFailToLoadAdForAdUnitIdentifier:(NSString *)adUnitIdentifier withError:(MAError *)error {
    if (isRewarded == YES) {
        [[LegacyManger shared] logEventForCall:@(loadRewardedVideoCount) withText:@"Did Fail (App)" adType:@"Rewarded"];
        if ([self.rewarded isReady]) {
            [self loadRewardedVideo];
        }
    }
    if (isBanner == YES) {
        [[LegacyManger shared] logEventForCall:@(loadBannerCount) withText:@"Did Fail (App)" adType:@"Banner"];
        [self loadBanner];
    }
    if (isInterstitial == YES) {
        [[LegacyManger shared] logEventForCall:@(loadInterstitialCount) withText:@"Did Fail (App)" adType:@"Interstitial"];
        if ([self.interstitialAd isReady]) {
            [self loadInterstitialVideo];
        }
    }
}

- (void)didClickAd:(nonnull MAAd *)ad { }

- (void)didDisplayAd:(nonnull MAAd *)ad { }

- (void)didFailToDisplayAd:(nonnull MAAd *)ad withError:(nonnull MAError *)error { }

- (void)didHideAd:(nonnull MAAd *)ad { }

- (void)didCollapseAd:(nonnull MAAd *)ad { }

- (void)didExpandAd:(nonnull MAAd *)ad { }

- (void)didRewardUserForAd:(nonnull MAAd *)ad withReward:(nonnull MAReward *)reward { }

@end

