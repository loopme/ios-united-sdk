//
//  GADLoopMeInterstitialAdapter.m
//  Bridge
//
//  Copyright (c) 2013 LoopMe. All rights reserved.
//

#import "GADLoopMeInterstitialAdapter.h"

@implementation GADLoopMeInterstitialAdapter

@synthesize delegate = _delegate;

- (void)requestInterstitialAdWithParameter:(NSString *)serverParameter label:(NSString *)serverLabel request:(GADCustomEventRequest *)request {

    self.loopMeInterstitial = [LoopMeInterstitial interstitialWithAppKey:serverParameter
                                                                delegate:self];
    [self.loopMeInterstitial loadAdWithTargeting:nil integrationType:@"admob"];

}

- (void)presentFromRootViewController:(UIViewController *)rootViewController {
    [self.loopMeInterstitial showFromViewController:rootViewController animated:YES];
}

#pragma mark -
#pragma mark LoopMe Interstitial Delegate

- (void)loopMeInterstitialDidExpire:(LoopMeInterstitial *)interstitial {
    NSLog(@"LoopMe interstitial ad is expired. Not supported!");
    //    Not supported in custom event delegate
}

- (void)loopMeInterstitialDidLoadAd:(LoopMeInterstitial *)interstitial {
    NSLog(@"LoopMe interstitial did load");
    [self.delegate customEventInterstitialDidReceiveAd:self];
}

- (void)loopMeInterstitial:(LoopMeInterstitial *)interstitial didFailToLoadAdWithError:(NSError *)error {
    NSLog(@"LoopMe interstitial did fail with error: %@", [error localizedDescription]);
    [self.delegate customEventInterstitial:self didFailAd:error];
}

- (void)loopMeInterstitialWillAppear:(LoopMeInterstitial *)interstitial {
    NSLog(@"LoopMe interstitial will present");
    [self.delegate customEventInterstitialWillPresent:self];
}

- (void)loopMeInterstitialDidAppear:(LoopMeInterstitial *)interstitial {
    NSLog(@"LoopMe interstitial did present. Not supported!");
}

- (void)loopMeInterstitialDidDisappear:(LoopMeInterstitial *)interstitial {
    NSLog(@"LoopMe interstitial did dismiss");
    [self.delegate customEventInterstitialDidDismiss:self];
}

- (void)loopMeInterstitialWillDisappear:(LoopMeInterstitial *)interstitial {
    NSLog(@"LoopMe interstitial will dismiss");
    [self.delegate customEventInterstitialWillDismiss:self];
}

- (void)loopMeInterstitialDidReceiveTap:(LoopMeInterstitial *)interstitial {
    NSLog(@"LoopMe interstitial was tapped. Not supported!");
    [self.delegate customEventInterstitialWasClicked:self];
}

- (void)loopMeInterstitialWillLeaveApplication:(LoopMeInterstitial *)interstitial {
    NSLog(@"LoopMe interstitial will leave application");
    [self.delegate customEventInterstitialWillLeaveApplication:self];
}

- (void)loopMeInterstitialVideoDidReachEnd:(LoopMeInterstitial *)interstitial {
    NSLog(@"LoopMe interstitial video did reach end. Not supported!");
}

@end
