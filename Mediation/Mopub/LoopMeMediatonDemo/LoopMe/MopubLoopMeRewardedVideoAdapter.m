//
//  MopubLoopMeRewardedVideoAdapter.m
//  Bridge
//
//

#import "MopubLoopMeRewardedVideoAdapter.h"
#import "MPRewardedVideoReward.h"
#import "MPLogging.h"
#import "MPError.h"
#import "LMInstanceProvider.h"

@interface MopubLoopMeRewardedVideoAdapter ()

@property (nonatomic) MPReward *reward;

@end

@implementation MopubLoopMeRewardedVideoAdapter

#pragma mark - Custom Event delegates

- (void)requestAdWithAdapterInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    if (![info objectForKey:@"app_key"]) {
        // MPError with invalid error code, in fact wrong json format
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:[NSError errorWithCode:MOPUBErrorAdapterInvalid]];
        return;
    }
    
    NSString *appKey = [info objectForKey:@"app_key"];
    if (!self.loopmeInterstitial) {
        self.loopmeInterstitial = [[LMInstanceProvider sharedProvider] buildLoopMeInterstitialWithAppKey:appKey
                                                                                            delegate:self];
    }
    
    if (!self.loopmeInterstitial) {
        // MPError with invalid error code, in fact old iOS version
        [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:[NSError errorWithCode:MOPUBErrorAdapterInvalid]];
        return;
    }
    
    NSString *currencyType;
    NSNumber *amount;
    if ([info objectForKey:@"currency_type"]) {
        currencyType = [info objectForKey:@"currency_type"];
    } else {
        currencyType = kMPRewardCurrencyTypeUnspecified;
    }
    
    if ([info objectForKey:@"amount"]) {
        amount = [NSNumber numberWithDouble:[[info objectForKey:@"amount"] doubleValue]];
    } else {
        amount = [NSNumber numberWithInteger:kMPRewardCurrencyAmountUnspecified];
    }
    
    _reward = [[MPReward alloc] initWithCurrencyType:currencyType amount:amount];
    [self.loopmeInterstitial loadAdWithTargeting:nil integrationType:@"mopub"];
}

- (BOOL)hasAdAvailable {
    return self.loopmeInterstitial.isReady;
}

- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController {
    if (!self.loopmeInterstitial.isReady) {
        MPLogInfo(@"Failed to show LoopMe interstitial: a previously loaded LoopMe interstitial now claims not to be ready.");
        return;
    }
    
    [self.loopmeInterstitial showFromViewController:viewController animated:YES];
}

#pragma mark - LoopMeInterstitial delegates

- (void)loopMeInterstitialDidLoadAd:(LoopMeInterstitial *)interstitial {
    MPLogInfo(@"LoopMe interstitial did load");
    [self.delegate fullscreenAdAdapterDidLoadAd:self];
}

- (void)loopMeInterstitial:(LoopMeInterstitial *)interstitial didFailToLoadAdWithError:(NSError *)error {
    MPLogInfo(@"LoopMe interstitial did fail with error: %@", [error localizedDescription]);
    [self.delegate fullscreenAdAdapter:self didFailToLoadAdWithError:error];
}

- (void)loopMeInterstitialWillAppear:(LoopMeInterstitial *)interstitial {
    MPLogInfo(@"LoopMe interstitial will present");
    [self.delegate fullscreenAdAdapterAdWillAppear:self];
}

- (void)loopMeInterstitialDidAppear:(LoopMeInterstitial *)interstitial {
    MPLogInfo(@"LoopMe interstitial did present");
    [self.delegate fullscreenAdAdapterAdDidAppear:self];
}

- (void)loopMeInterstitialWillDisappear:(LoopMeInterstitial *)interstitial {
    MPLogInfo(@"LoopMe interstitial will dismiss");
    [self.delegate fullscreenAdAdapterAdWillDisappear:self];
}

- (void)loopMeInterstitialDidDisappear:(LoopMeInterstitial *)interstitial {
    MPLogInfo(@"LoopMe interstitial did dismiss");
    [self.delegate fullscreenAdAdapterAdDidDisappear:self];
}

- (void)loopMeInterstitialDidReceiveTap:(LoopMeInterstitial *)interstitial {
    MPLogInfo(@"LoopMe interstitial was tapped");
    [self.delegate fullscreenAdAdapterDidReceiveTap:self];
}

- (void)loopMeInterstitialWillLeaveApplication:(LoopMeInterstitial *)interstitial {
    MPLogInfo(@"LoopMe interstitial will leave application");
    [self.delegate fullscreenAdAdapterWillLeaveApplication:self];
}

- (void)loopMeInterstitialDidExpire:(LoopMeInterstitial *)interstitial {
    MPLogInfo(@"LoopMe interstitial did expire");
    [self.delegate fullscreenAdAdapterDidExpire:self];
}

- (void)loopMeInterstitialVideoDidReachEnd:(LoopMeInterstitial *)interstitial{
    MPLogInfo(@"LoopMe interstitial video did reach end.");
    [self.delegate fullscreenAdAdapter:self willRewardUser:self.reward];
}

@end
