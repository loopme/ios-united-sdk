//
//  LDBannerViewController.m
//  LoopmeDemo
//
//  Copyright (c) 2015 Loopmemedia. All rights reserved.
//

#import "LDBannerViewController.h"
#import <LoopMeUnitedSDK/LoopMeAdView.h>

const float kLDAdViewWidth = 320.0f;
const float kLDAdViewHeight = 50.0f;

@interface LDBannerViewController ()
<
    LoopMeAdViewDelegate
>
@property (nonatomic, strong) LoopMeAdView *adView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *progressView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *bannerPlacement;

@property (nonatomic) CGPoint initialCenter;

@end

@implementation LDBannerViewController

- (LoopMeAdView *)adView {
    if (_adView == nil) {
        CGRect adFrame = CGRectMake(0, 0, kLDAdViewWidth, kLDAdViewHeight);

        self.appKey = @"31d9f96d32";
        // Intializing `LoopMeAdView`
        _adView = [LoopMeAdView adViewWithAppKey:self.appKey
                                           frame:adFrame viewControllerForPresentationGDPRWindow: self 
                                        delegate:self];
    }
    return _adView;
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Ad View"];
    [self.progressView setHidesWhenStopped:true];
    [self.progressView startAnimating];
    [self.bannerPlacement addSubview:self.adView];
    [self.adView loadAd];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - Actions

- (IBAction)showButton_Click:(id)sender
{
    if (self.adView.superview) {
        [self.adView removeFromSuperview];
        self.adView = nil;        
    }
    [self.adView loadAd];
    [self.progressView startAnimating];
}

#pragma mark - LoopMeAdViewDelegate

- (void)loopMeAdViewDidLoadAd:(LoopMeAdView *)adView
{
    [self.progressView stopAnimating];
}

- (void)loopMeAdView:(LoopMeAdView *)adView didFailToLoadAdWithError:(NSError *)error
{
    [self.progressView stopAnimating];
    [adView loadAd];
}

- (UIViewController *)viewControllerForPresentation
{
    return self;
}

@end
