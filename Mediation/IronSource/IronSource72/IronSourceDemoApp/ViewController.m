//
//  ViewController.m
//  IronSourceDemoApp
//
//  Copyright © 2017 IronSource. All rights reserved.
//

#import "ViewController.h"
#import <IronSource/IronSource.h>
#import "ISLoopmeCustomInterstitial.h"
#import "LoopMeUnitedSDK/LoopMeSDK.h"

#define USERID @"demoapp"
#define APPKEY @"127d76565"

@interface ViewController () <ISRewardedVideoDelegate ,ISInterstitialDelegate ,ISImpressionDataDelegate>

@property (weak, nonatomic) IBOutlet UIButton *showRVButton;
@property (weak, nonatomic) IBOutlet UIButton *loadRVButton;
@property (weak, nonatomic) IBOutlet UIButton *showISButton;
@property (weak, nonatomic) IBOutlet UIButton *loadISButton;
@property (weak, nonatomic) IBOutlet UITextField *rvAppKey;
@property (weak, nonatomic) IBOutlet UITextField *interstitialAppKey;

@property (nonatomic, strong) ISPlacementInfo   *rvPlacementInfo;
@end

@implementation ViewController

#pragma mark -
#pragma mark Lifecycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[LoopMeSDK shared] initSDKFromRootViewController:self completionBlock:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"%@", error);
        }
    }];




    
    for (UIButton *button in @[self.showISButton, self.loadRVButton, self.showRVButton, self.loadISButton]) {
        button.layer.cornerRadius = 17.0f;
        button.layer.masksToBounds = YES;
        button.layer.borderWidth = 3.5f;
        button.layer.borderColor = [[UIColor grayColor] CGColor];
    }
    
    [ISSupersonicAdsConfiguration configurations].useClientSideCallbacks = @(YES);
    
    // Before initializing any of our products (Rewarded video, Offerwall, Interstitial or Banner) you must set
    // their delegates. Take a look at each of there delegates method and you will see that they each implement a product
    // protocol. This is our way of letting you know what's going on, and if you don't set the delegates
    // we will not be able to communicate with you.
    // We're passing 'self' to our delegates because we want
    // to be able to enable/disable buttons to match ad availability.
    
    [IronSource setRewardedVideoDelegate:self];
    [IronSource setInterstitialDelegate:self];
    [IronSource addImpressionDataDelegate:self];

    NSString *userId = [IronSource advertiserId];
    
    if([userId length] == 0){
        //If we couldn't get the advertiser id, we will use a default one.
        userId = USERID;
    }
    
    // After setting the delegates you can go ahead and initialize the SDK.
    [IronSource setUserId:userId];
    
    [IronSource initWithAppKey:APPKEY];
    // To initialize specific ad units:
    // [IronSource initWithAppKey:APPKEY adUnits:@[IS_REWARDED_VIDEO, IS_INTERSTITIAL, IS_OFFERWALL, IS_BANNER]];
    
    // Scroll down the file to find out what happens when you click a button...
    
    /* 
     * Banner integration
     * To finalize your banner integration, you must integrate at least one of our mediation adapters that have banner.
     */

    [IronSource loadRewardedVideo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Interface Handling

- (IBAction)loadRVButtonTapped:(id)sender {
    NSString *appkey = self.rvAppKey.text;
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        [standardUserDefaults setObject:appkey forKey:@"LOOPME_INTERSTITIAL"];
        [standardUserDefaults synchronize];
    }
    [IronSource loadRewardedVideo];
}
- (IBAction)showRVButtonTapped:(id)sender {
    
    // After calling 'setRVDelegate' and 'initRVWithAppKey:withUserId'
    // you are ready to present an ad. You can supply a placement
    // by calling 'showRVWithPlacementName', or you can simply
    // call 'showRV'. In this case the SDK will use the default
    // placement one created for you.
    [IronSource showRewardedVideoWithViewController:self];
}


- (IBAction)showISButtonTapped:(id)sender {
    
    // This will present the Interstitial. Unlike Rewarded
    // Videos there are no placements.
    [IronSource showInterstitialWithViewController:self];
}

- (IBAction)loadISButtonTapped:(id)sender {
    NSString *appkey = self.rvAppKey.text;
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        [standardUserDefaults setObject:appkey forKey:@"LOOPME_INTERSTITIAL"];
        [standardUserDefaults synchronize];
    }
    // This will load the Interstitial. Unlike Rewarded
    // Videos there are no placements.
    [IronSource loadInterstitial];
}

#pragma mark - Rewarded Video Delegate Functions

// This method lets you know whether or not there is a video
// ready to be presented. It is only after this method is invoked
// with 'hasAvailableAds' set to 'YES' that you can should 'showRV'.
- (void)rewardedVideoHasChangedAvailability:(BOOL)available {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.showRVButton setEnabled:available];
    });
}

// This method gets invoked after the user has been rewarded.
- (void)didReceiveRewardForPlacement:(ISPlacementInfo *)placementInfo {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self.rvPlacementInfo = placementInfo;
}

// This method gets invoked when there is a problem playing the video.
// If it does happen, check out 'error' for more information and consult
// our knowledge center for help.
- (void)rewardedVideoDidFailToShowWithError:(NSError *)error {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

// This method gets invoked when we take control, but before
// the video has started playing.
- (void)rewardedVideoDidOpen {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

// This method gets invoked when we return controlback to your hands.
// We chose to notify you about rewards here and not in 'didReceiveRewardForPlacement'.
// This is because reward can occur in the middle of the video.
- (void)rewardedVideoDidClose {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (self.rvPlacementInfo) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Reward"
                                                        message:[NSString stringWithFormat:@"You have been rewarded %d %@", [self.rvPlacementInfo.rewardAmount intValue], self.rvPlacementInfo.rewardName]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        self.rvPlacementInfo = nil;
    }
}

// This method gets invoked when the video has started playing.
- (void)rewardedVideoDidStart {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

// This method gets invoked when the video has stopped playing.
- (void)rewardedVideoDidEnd {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

// This method gets invoked after a video has been clicked
- (void)didClickRewardedVideo:(ISPlacementInfo *)placementInfo {
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

#pragma mark - Interstitial Delegate Functions

- (void)interstitialDidLoad {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.showISButton setEnabled:YES];
    });
}

- (void)interstitialDidFailToLoadWithError:(NSError *)error {
    NSLog(@"%s",__PRETTY_FUNCTION__);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.showISButton setEnabled:NO];
    });
}

- (void)interstitialDidOpen {
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

// The method will be called each time the Interstitial windows has opened successfully.
- (void)interstitialDidShow {
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

// This method gets invoked after a failed attempt to load Interstitial.
// If it does happen, check out 'error' for more information and consult our
// Knowledge center.
- (void)interstitialDidFailToShowWithError:(NSError *)error {
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

// This method will be called each time the user had clicked the Interstitial ad.
- (void)didClickInterstitial {
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

// This method get invoked after the Interstitial window had closed and control
// returns to your application.
- (void)interstitialDidClose {
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

#pragma mark - Impression data Delegate Functions
- (void)impressionDataDidSucceed:(ISImpressionData *)impressionData {
    NSLog(@"impressionData %@",impressionData);
}

@end
