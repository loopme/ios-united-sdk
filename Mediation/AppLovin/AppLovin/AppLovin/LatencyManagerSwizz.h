//
//  LatencyManagerSwizz.h
//  AppLovinDemoApp
//
//  Created by Valerii Roman on 25/07/2024.
//

#ifndef LatencyManagerSwizz_h
#define LatencyManagerSwizz_h
#import "LoopMeUnitedSDK/LoopMeSDK.h"
#import <AppLovinDemoApp-Swift.h>
#import <AppLovinSDK/AppLovinSDK.h>
#import "LoopmeMediationAdapter.h"
#import <LoopMeUnitedSDK/LoopMeAdDisplayControllerNormal.h>
#import <objc/runtime.h>

#endif /* LatencyManagerSwizz_h */

//MARK: - LoopMeSDK
@implementation LoopMeInterstitial (loadAd)

//Interstitial
-(void)swizzle_loopMeInterstitialDidLoadAd: (LoopMeInterstitial *)interstitial {
    [self swizzle_loopMeInterstitialDidLoadAd: interstitial];
    [[LegacyManger shared] logEventForCall: nil withText: @"Did Load (SDK)" adType: nil];
}

-(void)swizzle_loopMeInterstitial: (LoopMeInterstitialGeneral *)interstitial didFailToLoadAdWithError: (NSError *)error {
    [self swizzle_loopMeInterstitial:interstitial didFailToLoadAdWithError:error];
    [[LegacyManger shared] logEventForCall: nil withText: @"Did Fail (SDK)" adType: nil];
}

-(void)swizzle_loadAd {
    [self swizzle_loadAd];
    [[LegacyManger shared] logEventForCall: nil withText: @"Load (SDK)" adType: nil];
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        // Swizzle loadAd:
        Method originalMethod = class_getInstanceMethod(class, @selector(loadAd));
        Method swizzledMethod = class_getInstanceMethod(class, @selector(swizzle_loadAd));
        method_exchangeImplementations(originalMethod, swizzledMethod);
        
        // Swizzle loopMeInterstitialDidLoadAd:
        Method loopmeInterstitialDidLoadAdOrigignal = class_getInstanceMethod(class, @selector(loopMeInterstitialDidLoadAd:));
        Method loopmeInterstitialDidLoadAdSwizzle = class_getInstanceMethod(class, @selector(swizzle_loopMeInterstitialDidLoadAd:));
        method_exchangeImplementations(loopmeInterstitialDidLoadAdOrigignal, loopmeInterstitialDidLoadAdSwizzle);

        // Swizzle loopMeInterstitial:didFailToLoadAdWithError:
        Method didFailToLoadAdWithErrorOriginal = class_getInstanceMethod(class, @selector(loopMeInterstitial:didFailToLoadAdWithError:));
        Method didFailToLoadAdWithErrorSwizzle = class_getInstanceMethod(class, @selector((swizzle_loopMeInterstitial:didFailToLoadAdWithError:)));
        method_exchangeImplementations(didFailToLoadAdWithErrorOriginal, didFailToLoadAdWithErrorSwizzle);
        
    });
}
@end

//MARK: Banner SDK
@implementation LoopMeAdView (Swizzling)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];

        // Swizzle loadAd
        Method originalLoadAdMethod = class_getInstanceMethod(class, @selector(loadAd));
        Method swizzledLoadAdMethod = class_getInstanceMethod(class, @selector(swizzle_loadAd));
        method_exchangeImplementations(originalLoadAdMethod, swizzledLoadAdMethod);

        // Swizzle adDisplayControllerDidFinishLoadingAd:
        Method originalDidLoadMethod = class_getInstanceMethod(class, @selector(adDisplayControllerDidFinishLoadingAd:));
        Method swizzledDidLoadMethod = class_getInstanceMethod(class, @selector(swizzle_adDisplayControllerDidFinishLoadingAd:));
        method_exchangeImplementations(originalDidLoadMethod, swizzledDidLoadMethod);

        // Swizzle failedLoadingAdWithError:
        Method originalDidFailMethod = class_getInstanceMethod(class, @selector(failedLoadingAdWithError:));
        Method swizzledDidFailMethod = class_getInstanceMethod(class, @selector(swizzle_failedLoadingAdWithError:));
        method_exchangeImplementations(originalDidFailMethod, swizzledDidFailMethod);

    });
}

- (void)swizzle_loadAd {
    [self swizzle_loadAd];
    [[LegacyManger shared] logEventForCall:nil withText:@"Load (SDK)" adType: nil];
}

- (void)swizzle_adDisplayControllerDidFinishLoadingAd: (LoopMeAdDisplayControllerNormal *)adDisplayController {
    [self swizzle_adDisplayControllerDidFinishLoadingAd: adDisplayController];
    [[LegacyManger shared] logEventForCall:nil withText:@"Did Load (SDK)" adType: nil];
}

- (void)swizzle_failedLoadingAdWithError: (NSError *)error  {
    [self swizzle_failedLoadingAdWithError:error];
    [[LegacyManger shared] logEventForCall:nil withText:@"Did Fail (SDK)" adType: nil];
}
@end


@implementation LoopmeMediationAdapter (Swizzling)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleOriginalSelector:@selector(loadInterstitialAdForParameters:andNotify:)
                      withSwizzledSelector:@selector(swizzled_loadInterstitialAdForParameters:andNotify:)];
        
        [self swizzleOriginalSelector:@selector(loadRewardedAdForParameters:andNotify:)
                      withSwizzledSelector:@selector(swizzled_loadRewardedAdForParameters:andNotify:)];
        
        [self swizzleOriginalSelector:@selector(loadAdViewAdForParameters:adFormat:andNotify:)
                      withSwizzledSelector:@selector(swizzled_loadAdViewAdForParameters:adFormat:andNotify:)];
        
        [self swizzleOriginalSelector:@selector(loopMeAdViewDidLoadAd:)
                      withSwizzledSelector:@selector(swizzled_loopMeAdViewDidLoadAd:)];
        [self swizzleOriginalSelector:@selector(loopMeAdView:didFailToLoadAdWithError:)
                      withSwizzledSelector:@selector(swizzled_loopMeAdView:didFailToLoadAdWithError:)];

    });
}


+ (void)swizzleOriginalSelector:(SEL)originalSelector withSwizzledSelector:(SEL)swizzledSelector {
    Class class = [self class];

    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));

    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

#pragma mark - Swizzled Methods

- (void)swizzled_loadInterstitialAdForParameters:(id<MAAdapterResponseParameters>)parameters
                                       andNotify:(id<MAInterstitialAdapterDelegate>)delegate {
    [self swizzled_loadInterstitialAdForParameters:parameters andNotify:delegate];
    [[LegacyManger shared] logEventForCall: nil withText:@"Load (Adapter)" adType: nil];

}

- (void)swizzled_loadRewardedAdForParameters:(id<MAAdapterResponseParameters>)parameters
                                   andNotify:(id<MARewardedAdapterDelegate>)delegate {
    [self swizzled_loadRewardedAdForParameters:parameters andNotify:delegate];
    [[LegacyManger shared] logEventForCall: nil withText:@"Load (Adapter)" adType: nil];
}

- (void)swizzled_loadAdViewAdForParameters:(id<MAAdapterResponseParameters>)parameters
                                  adFormat:(MAAdFormat *)adFormat
                                 andNotify:(id<MAAdViewAdapterDelegate>)delegate {
    [self swizzled_loadAdViewAdForParameters:parameters adFormat:adFormat andNotify:delegate];
    [[LegacyManger shared] logEventForCall: nil withText:@"Load (Adapter)" adType: nil];

}

- (void)swizzled_loopMeAdViewDidLoadAd:(LoopMeAdView *)adView {
    // Custom behavior before calling the original method
    [[LegacyManger shared] logEventForCall: nil withText:@"Did Load (Adapter)" adType: nil];

    // Call the original method (which is now swizzled to 'swizzled_loopMeAdViewDidLoadAd')
    [self swizzled_loopMeAdViewDidLoadAd:adView];
}

- (void)swizzled_loopMeAdView:(LoopMeAdView *)adView didFailToLoadAdWithError:(NSError *)error {
    // Custom behavior before calling the original method
    [[LegacyManger shared] logEventForCall: nil withText:@"Did Fail (Adapter)" adType: nil];

    // Call the original method (which is now swizzled to 'swizzled_loopMeAdView:didFailToLoadAdWithError:')
    [self swizzled_loopMeAdView:adView didFailToLoadAdWithError:error];
}

@end


