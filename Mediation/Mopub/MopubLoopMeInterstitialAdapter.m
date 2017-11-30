//
//  MopubLoopMeInterstitialAdapter.m
//  Bridge
//
//

#import "MopubLoopMeInterstitialAdapter.h"
#import "MPLogging.h"
#import "MPError.h"
#import "MPInstanceProvider+LoopMe.h"

@implementation MopubLoopMeInterstitialAdapter

#pragma mark - Custom Event delegates

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info {
    if (![info objectForKey:@"app_key"]) {
        // MPError with invalid error code, in fact wrong json format
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:[MOPUBError errorWithCode:MOPUBErrorAdapterInvalid]];
        return;
    }
    
    NSString *appKey = [info objectForKey:@"app_key"];
    if (!self.loopmeInterstitial) {
        self.loopmeInterstitial = [[MPInstanceProvider sharedProvider] buildLoopMeInterstitialWithAppKey:appKey delegate:self];
    }
        
    if (!self.loopmeInterstitial) {
        // MPError with invalid error code, in fact old iOS version
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:[MOPUBError errorWithCode:MOPUBErrorAdapterInvalid]];
        return;
    }
    
    [self.loopmeInterstitial loadAdWithTargeting:nil integrationType:@"mopub"];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController {
    if (!self.loopmeInterstitial.isReady) {
        MPLogInfo(@"Failed to show LoopMe interstitial: a previously loaded LoopMe interstitial now claims not to be ready.");
        return;
    }
    [self.loopmeInterstitial showFromViewController:rootViewController animated:YES];
}

#pragma mark - LoopMeInterstitial delegates

- (void)loopMeInterstitialDidLoadAd:(LoopMeInterstitial *)interstitial {
    MPLogInfo(@"LoopMe interstitial did load");
    [self.delegate interstitialCustomEvent:self didLoadAd:self];
}

- (void)loopMeInterstitial:(LoopMeInterstitial *)interstitial didFailToLoadAdWithError:(NSError *)error {
    MPLogInfo(@"LoopMe interstitial did fail with error: %@", [error localizedDescription]);
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)loopMeInterstitialWillAppear:(LoopMeInterstitial *)interstitial {
    MPLogInfo(@"LoopMe interstitial will present");
    [self.delegate interstitialCustomEventWillAppear:self];
}

- (void)loopMeInterstitialDidAppear:(LoopMeInterstitial *)interstitial {
    MPLogInfo(@"LoopMe interstitial did present");
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)loopMeInterstitialWillDisappear:(LoopMeInterstitial *)interstitial {
    MPLogInfo(@"LoopMe interstitial will dismiss");
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)loopMeInterstitialDidDisappear:(LoopMeInterstitial *)interstitial {
    MPLogInfo(@"LoopMe interstitial did dismiss");
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)loopMeInterstitialDidReceiveTap:(LoopMeInterstitial *)interstitial {
    MPLogInfo(@"LoopMe interstitial was tapped");
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
}

- (void)loopMeInterstitialWillLeaveApplication:(LoopMeInterstitial *)interstitial {
    MPLogInfo(@"LoopMe interstitial will leave application");
    [self.delegate interstitialCustomEventWillLeaveApplication:self];
}

- (void)loopMeInterstitialDidExpire:(LoopMeInterstitial *)interstitial {
    MPLogInfo(@"LoopMe interstitial did expire");
    [self.delegate interstitialCustomEventDidExpire:self];
}

- (void)loopMeInterstitialVideoDidReachEnd:(LoopMeInterstitial *)interstitial{
    MPLogInfo(@"LoopMe interstitial video did reach end. Not supported!");
}
@end
