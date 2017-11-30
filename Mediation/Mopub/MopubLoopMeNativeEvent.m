//
//  LoopMeNativeEvent.m
//  LoopMeMediatonDemo
//
//  Created by Dmitriy on 7/29/15.
//  Copyright (c) 2015 injectios. All rights reserved.
//

#import "LoopMeAdView.h"
#import "LoopMeError.h"
#import "LoopMeLogging.h"
#import "MopubLoopMeNativeEvent.h"
#import "MPNativeAd.h"
#import "MopubLoopMeNativeAd.h"
#import "MPError.h"

@interface MopubLoopMeNativeEvent ()
<
    LoopMeAdViewDelegate
>
@property (nonatomic, strong) LoopMeAdView *adView;

@end

@implementation MopubLoopMeNativeEvent

#pragma mark - MPNativeCustomEvent

- (void)requestAdWithCustomEventInfo:(NSDictionary *)info
{
    setLoopMeLogLevel(LoopMeLogLevelDebug);

    /*
     * Handling ad request incoming parameters
     */
    if (!info[@"app_key"]) {
        LoopMeLogDebug(@"Could not find appKey for LooopMe network");
        [self.delegate nativeCustomEvent:self
                didFailToLoadAdWithError:[LoopMeError errorForStatusCode:LoopMeErrorCodeIncorrectResponse]];
        return;
    }

    self.adView = [LoopMeAdView adViewWithAppKey:info[@"app_key"]
                                                    frame:CGRectZero
                                               scrollView:nil
                                                 delegate:self];

    if (!self.adView) {
        LoopMeLogDebug(@"Old iOS version");
        [self.delegate nativeCustomEvent:self
                didFailToLoadAdWithError:[MOPUBError errorWithCode:MOPUBErrorAdapterInvalid]];
        return;
    }
    /*
     * Important: ensure you are displaying ONLY one LoopMe video ad
     * OR disable it otherwise.
     * If theoretically more then one video ad would be displayed,
     * minimized ad view would screw up video ads.
     */
    // Enabling minimized ad during scroll
    if (info[@"minimized"]) {
        self.adView.minimizedModeEnabled = YES;
    }
    /*
     * Trigerring ad request
     * Optionally use -loadWithTargeting: in order to receive more relevant ads
     */
    [self.adView loadAdWithTargeting:nil integrationType:@"mopub"];
}

#pragma mark - LoopMeAdViewDelegate

- (void)loopMeAdView:(LoopMeAdView *)adView didFailToLoadAdWithError:(NSError *)error
{
    /*
     * Triggering -failLoad in order to let waterfall work properly
     */
    [self.delegate nativeCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)loopMeAdViewDidLoadAd:(LoopMeAdView *)adView
{
    /*
     * Initializing ad object to pass back to Mopub SDK and
     * triggering -finishLoad in order to let waterfall work properly.
     * Note that adapter is nil
     */
    MopubLoopMeNativeAd *ad = [[MopubLoopMeNativeAd alloc] initWithAdAdapter:nil];
    ad.adView = adView;
    [self.delegate nativeCustomEvent:self didLoadAd:ad];
}

/*
 * Returning nill for required delegate's method not to get warning.
 * We would reassign delegate to the controller from which we would display video ad later on
 */
- (UIViewController *)viewControllerForPresentation {
    return nil;
}

@end
