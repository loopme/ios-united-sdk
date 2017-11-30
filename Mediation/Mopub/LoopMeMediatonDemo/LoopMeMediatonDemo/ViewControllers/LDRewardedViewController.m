//
//  LDInterstitialViewController.m
//  LoopMeMediatonDemo
//
//  Created by Bohdan on 4/13/17.
//  Copyright © 2017 injectios. All rights reserved.
//

#import "LDRewardedViewController.h"
#import "MoPub.h"
#import "MPRewardedVideo.h"

NSString * const kMopubAdUnitID = @"4c2678be84404c7184f8aa1947f8b8fb";

@interface LDRewardedViewController ()
<
    MPRewardedVideoDelegate
>

@end

@implementation LDRewardedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[MoPub sharedInstance] initializeRewardedVideoWithGlobalMediationSettings:nil delegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loadClick:(id)sender {
    [MPRewardedVideo loadRewardedVideoAdWithAdUnitID:kMopubAdUnitID withMediationSettings:nil];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)rewardedVideoAdDidLoadForAdUnitID:(NSString *)adUnitID {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if ([MPRewardedVideo hasAdAvailableForAdUnitID:kMopubAdUnitID]) {
        [MPRewardedVideo presentRewardedVideoAdForAdUnitID:kMopubAdUnitID fromViewController:self];
    }
}

- (void)rewardedVideoAdDidFailToLoadForAdUnitID:(NSString *)adUnitID error:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
