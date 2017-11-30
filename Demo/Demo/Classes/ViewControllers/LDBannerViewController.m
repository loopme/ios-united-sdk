//
//  LDBannerViewController.m
//  LoopmeDemo
//
//  Copyright (c) 2015 Loopmemedia. All rights reserved.
//

#import "LDBannerViewController.h"
#import "UIImage+iphone5.h"

#import <LoopMeUnitedSDK/LoopMeAdView.h>

const float kLDAdViewHeight = 168.75; // Video dimension 16x9
const float kLDAdViewWidth = 300.0f;

@interface LDBannerViewController ()
<
    LoopMeAdViewDelegate
>
@property (nonatomic, strong) LoopMeAdView *adView;
@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *progressView;

@end

@implementation LDBannerViewController

- (LoopMeAdView *)adView {
    if (_adView == nil) {
        CGRect adFrame = CGRectMake(0, 0, kLDAdViewWidth, kLDAdViewHeight);

        // Intializing `LoopMeAdView`
        _adView = [LoopMeAdView adViewWithAppKey:TEST_APP_KEY_MPU
                                           frame:adFrame
                                        delegate:self];
    }
    return _adView;
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.background.image = [UIImage imageNamedForDevice:@"bg_new_main"];
    }    
    [self.view addSubview:self.progressView];
    [self setTitle:@"Ad View"];
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
    adView.center = self.progressView.center;
    [self.view addSubview:adView];
    [self.progressView stopAnimating];
}

- (void)loopMeAdView:(LoopMeAdView *)adView didFailToLoadAdWithError:(NSError *)error
{
    [self.progressView stopAnimating];
}

- (UIViewController *)viewControllerForPresentation
{
    return self;
}

@end
