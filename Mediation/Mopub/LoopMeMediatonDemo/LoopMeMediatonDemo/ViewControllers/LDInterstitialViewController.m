//
//  LDInterstitialViewController.m
//  LoopMeMediatonDemo
//
//  Created by Bohdan on 4/13/17.
//  Copyright © 2017 injectios. All rights reserved.
//

#import "LDInterstitialViewController.h"
#import "MPInterstitialAdController.h"

@interface LDInterstitialViewController ()
<
    MPInterstitialAdControllerDelegate
>

@property (nonatomic) MPInterstitialAdController *interstitial;
@property (weak, nonatomic) IBOutlet UIButton *loadButton;
@property (weak, nonatomic) IBOutlet UIButton *showButton;

@end

@implementation LDInterstitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.interstitial = [MPInterstitialAdController interstitialAdControllerForAdUnitId:@"e0f79a7b925b424e9159e2e1d2a0777b"];
    self.interstitial.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loadClick:(id)sender {
    [self.interstitial loadAd];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (IBAction)showClick:(id)sender {
    [self.interstitial showFromViewController:self];
}

- (void)interstitialDidLoadAd:(MPInterstitialAdController *)interstitial {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.showButton.enabled = YES;
}

- (void)interstitialDidFailToLoadAd:(MPInterstitialAdController *)interstitial {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    self.showButton.enabled = NO;
}

- (void)interstitialDidDisappear:(MPInterstitialAdController *)interstitial {
    if ([self.interstitial ready]) {
        self.showButton.enabled = YES;
    } else {
        self.showButton.enabled = NO;
    }
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
