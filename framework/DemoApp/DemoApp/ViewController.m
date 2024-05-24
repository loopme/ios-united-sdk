//
//  ViewController.m
//  DemoApp
//
//  Created by Valerii Roman on 24/05/2024.
//

#import "ViewController.h"
#import "LoopMeUnitedSDK/LoopMeSDK.h"
#import "LoopMeUnitedSDK/LoopMeInterstitial.h"


@interface ViewController ()
@property (nonatomic, strong) LoopMeInterstitial *interstitial;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[LoopMeSDK shared] initSDKFromRootViewController:self completionBlock:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"%@", error);
        }
    }];
}
- (IBAction)loadInterstitial:(id)sender {
    self.interstitial = [LoopMeInterstitial interstitialWithAppKey:@"dafa602ab1" delegate:self];
    [self.interstitial setAutoLoadingEnabled:FALSE];
    [self.interstitial loadAd];
    
}

- (IBAction)showInterstiail:(id)sender {
    if (![self.interstitial isReady]) {
        return;
    }
    [self.interstitial showFromViewController:self animated:YES];

}



@end
