//
//  ViewController.m
//  AdMobAdapter
//
//  Created by Bohdan on 8/18/16.
//  Copyright © 2016 LoopMe. All rights reserved.
//

#import "ViewController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <LoopMeUnitedSDK/LoopMeSDK.h>

@import GoogleMobileAds;

@interface ViewController () <GADFullScreenContentDelegate>

@property(nonatomic, strong) GADInterstitialAd *interstitial;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)load:(id)sender {
    [[GADMobileAds sharedInstance] startWithCompletionHandler:nil];
    [GADInterstitialAd loadWithAdUnitID:@"ca-app-pub-1429938838258792/7046510669"
                                request:[GADRequest request]
                      completionHandler:^(GADInterstitialAd *ad, NSError *error) {
      if (error) {
        NSLog(@"Failed to load an interstitial ad with error: %@", error.localizedDescription);
        return;
      }
      self.interstitial = ad;
      self.interstitial.fullScreenContentDelegate = self;
        [self.interstitial presentFromRootViewController:self];
    }];
}


- (void)interstitialDidReceiveAd:(nonnull id<GADFullScreenPresentingAd>)ad {
    [self.interstitial presentFromRootViewController:self];
}

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(NSError *)error {
  NSLog(@"%@ failed with error: %@", adLoader, error.localizedDescription);
}

- (void)interstitialDidDismissScreen:(nonnull id<GADFullScreenPresentingAd>)ad{

}

@end
