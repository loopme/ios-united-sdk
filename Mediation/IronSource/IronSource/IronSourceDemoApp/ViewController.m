//
//  ViewController.m
//  IronSourceDemoApp
//
//  Copyright © 2017 IronSource. All rights reserved.
//

#import "ViewController.h"
#import <IronSource/IronSource.h>
#import "LoopMeUnitedSDK/LoopMeSDK.h"

#define USERID @"demoapp"
#define APPKEY @"1c524597d"

@implementation ViewController

- (void)hideKeyboard: (UITapGestureRecognizer*)sender {
    [self.view endEditing: YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showAlertVC = YES;
    
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

    NSString *userId = [IronSource advertiserId];
    if([userId length] == 0) {
        // If we couldn't get the advertiser id, we will use a default one.
        userId = USERID;
    }
    
    // After setting the delegates you can go ahead and initialize the SDK.
    [IronSource setUserId: userId];
    [IronSource initWithAppKey: APPKEY];
    [self.view addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(hideKeyboard:)]];
}

- (void)keyboardWillShow: (NSNotification *)notification {
    [UIView animateWithDuration: 0.3 animations: ^{
        CGRect f = self.view.frame;
        CGSize keyboardSize = [[[notification userInfo] objectForKey: UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        f.origin.y = -keyboardSize.height /2;
        self.view.frame = f;
    }];
}

- (void)keyboardWillHide: (NSNotification *)notification {
    [UIView animateWithDuration: 0.3 animations: ^{
        CGRect f = self.view.frame;
        f.origin.y = 0.0f;
        self.view.frame = f;
    }];
}

- (void)viewWillAppear: (BOOL)animated {
    [super viewWillAppear: animated];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillShow:)
                                                 name: UIKeyboardWillShowNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillHide:)
                                                 name: UIKeyboardWillHideNotification
                                               object: nil];
}

- (void)viewWillDisappear: (BOOL)animated {
    [super viewWillDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: UIKeyboardWillShowNotification object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: UIKeyboardWillHideNotification object: nil];
}

-(void)showText: (NSString *)message{
    if (!self.showAlertVC) {
        return;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: nil
                                                                   message: message
                                                            preferredStyle: UIAlertControllerStyleAlert];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated: YES completion: nil];
    });
    
    [self presentViewController: alert animated: YES completion: nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Interface Handling

- (IBAction)loadRVButtonTapped: (id)sender {
    self.showAlertVC = YES;
    [IronSource loadRewardedVideo];
}
- (IBAction)showRVButtonTapped: (id)sender {
    // After calling 'setRVDelegate' and 'initRVWithAppKey:withUserId'
    // you are ready to present an ad. You can supply a placement
    // by calling 'showRVWithPlacementName', or you can simply
    // call 'showRV'. In this case the SDK will use the default
    // placement one created for you
    self.showAlertVC = NO;
    [IronSource showRewardedVideoWithViewController: self];
}

- (IBAction)loadISButtonTapped: (id)sender {
    // This will load the Interstitial. Unlike Rewarded
    // Videos there are no placements.
    self.showAlertVC = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [IronSource loadInterstitial];
    });
}
- (IBAction)showISButtonTapped: (id)sender {
    // This will present the Interstitial. Unlike Rewarded
    // Videos there are no placements
    self.showAlertVC = NO;
    [IronSource showInterstitialWithViewController: self];
}

- (IBAction)loadBannerButtonTapped: (UIButton *)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.showAlertVC = YES;
        // ISBannerSize *leaderboardSize = [[ISBannerSize alloc] initWithWidth:self.view.frame.size.width andHeight:90];
        [IronSource loadBannerWithViewController: self size: ISBannerSize_BANNER];
    });
}

- (IBAction)destroyBanner: (UIButton *)sender {
    [IronSource destroyBanner: self.banner];
}

/**
 Called after an rewarded video has been loaded in manual mode
 @param adInfo The info of the ad.
 */
- (void)didLoadWithAdInfo: (ISAdInfo *)adInfo{
    NSLog(@"didLoadWithAdInfo: %@", adInfo);
    [self showText: [NSString stringWithUTF8String: __PRETTY_FUNCTION__]];
    if ([adInfo.ad_unit isEqual: @"interstitial"])
        _showISButton.enabled = YES;
    else
        _showRVButton.enabled = YES;
}

/**
 Called after a rewarded video has attempted to load but failed in manual mode
 @param error The reason for the error
 */
- (void)didFailToLoadWithError: (NSError *)error {
    NSLog(@"didFailToLoadWithError: %@", error);
    [self showText: error.localizedDescription];
}

/**
 Called after a rewarded video has been viewed completely and the user is eligible for a reward.
 @param placementInfo An object that contains the placement's reward name and amount.
 @param adInfo The info of the ad.
 */
- (void)didReceiveRewardForPlacement: (ISPlacementInfo *)placementInfo withAdInfo: (ISAdInfo *)adInfo {
    NSLog(@"didReceiveRewardForPlacement: %@\n%@", adInfo, placementInfo);
    [self showText: [NSString stringWithUTF8String: __PRETTY_FUNCTION__]];
}

/**
 Called after a rewarded video has attempted to show but failed.
 @param error The reason for the error
 @param adInfo The info of the ad.
 */
- (void)didFailToShowWithError: (NSError *)error andAdInfo: (ISAdInfo *)adInfo {
    NSLog(@"didFailToShowWithError: %@\n%@", adInfo, error);
    [self showText: [NSString stringWithUTF8String: __PRETTY_FUNCTION__]];
}

/**
 Called after a rewarded video has been opened.
 @param adInfo The info of the ad.
 */
- (void)didOpenWithAdInfo: (ISAdInfo *)adInfo {
    NSLog(@"didOpenWithAdInfo: %@", adInfo);
    [self showText: [NSString stringWithUTF8String: __PRETTY_FUNCTION__]];
}

/**
 Called after a rewarded video has been dismissed.
 @param adInfo The info of the ad.
 */
- (void)didCloseWithAdInfo: (ISAdInfo *)adInfo {
    NSLog(@"didCloseWithAdInfo: %@", adInfo);
    [self showText: [NSString stringWithUTF8String: __PRETTY_FUNCTION__]];
    if ([adInfo.ad_unit isEqual: @"interstitial"])
        _showISButton.enabled = NO;
    else
        _showRVButton.enabled = NO;
}

/**
 Called after a rewarded video has been clicked.
 This callback is not supported by all networks, and we recommend using it
 only if it's supported by all networks you included in your build
 @param adInfo The info of the ad.
 */
- (void)didClick: (ISPlacementInfo *)placementInfo withAdInfo: (ISAdInfo *)adInfo {
    NSLog(@"didClick: %@\n%@", adInfo, placementInfo);
    [self showText: [NSString stringWithUTF8String: __PRETTY_FUNCTION__]];
}

/**
 Called after an interstitial has been clicked.
 @param adInfo The info of the ad.
 */
- (void)didClickWithAdInfo: (ISAdInfo *)adInfo {
    NSLog(@"didClickWithAdInfo: %@", adInfo);
    [self showText: [NSString stringWithUTF8String: __PRETTY_FUNCTION__]];
}

- (void)didLoad: (ISBannerView *)bannerView withAdInfo: (ISAdInfo *)adInfo {
    NSLog(@"didLoad: %@", adInfo);
    [self showText: [NSString stringWithUTF8String: __PRETTY_FUNCTION__]];
    CGFloat viewCenterX = self.view.center.x;
    CGFloat viewСenterY = (self.view.frame.size.height - (bannerView.frame.size.height / 2.0) - self.view.safeAreaInsets.bottom);
    self.banner = bannerView;
    dispatch_async(dispatch_get_main_queue(), ^{
       [self.banner setCenter: CGPointMake(viewCenterX, viewСenterY)];
       [self.view addSubview: self.banner];
    });
}

- (void)didDismissScreenWithAdInfo: (ISAdInfo *)adInfo {
    NSLog(@"[ISAdapter] - didDismissScreenWithAdInfo");
}


- (void)didLeaveApplicationWithAdInfo: (ISAdInfo *)adInfo {
    NSLog(@"[ISAdapter] - didLeaveApplicationWithAdInfo");
}


- (void)didPresentScreenWithAdInfo: (ISAdInfo *)adInfo {
    NSLog(@"[ISAdapter] - didPresentScreenWithAdInfo");
}

/**
 Called after an interstitial has been displayed on the screen.
 This callback is not supported by all networks, and we recommend using it
 only if it's supported by all networks you included in your build.
 @param adInfo The info of the ad.
 */
- (void)didShowWithAdInfo: (ISAdInfo *)adInfo {
    NSLog(@"didShowWithAdInfo: %@", adInfo);
    [self showText: [NSString stringWithUTF8String: __PRETTY_FUNCTION__]];
}

@end
