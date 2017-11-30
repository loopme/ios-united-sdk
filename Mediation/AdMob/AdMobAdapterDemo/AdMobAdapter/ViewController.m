//
//  ViewController.m
//  AdMobAdapter
//
//  Created by Bohdan on 8/18/16.
//  Copyright © 2016 LoopMe. All rights reserved.
//

#import "ViewController.h"

@import GoogleMobileAds;

@interface ViewController () <GADInterstitialDelegate>

@property(nonatomic, strong) GADInterstitial *interstitial;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)load:(id)sender {
    self.interstitial =
    [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-1429938838258792/7046510669"];
    self.interstitial.delegate = self;
    GADRequest *request = [GADRequest request];
    
    [self.interstitial loadRequest:request];
}


- (void)interstitialDidReceiveAd:(GADInterstitial *)ad {
    [self.interstitial presentFromRootViewController:self];
}

- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error {
    
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad {

}

@end
