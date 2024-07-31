//
//  LatencyManagerSwizz.h
//  IronSourceDemoApp
//
//  Created by Valerii Roman on 23/07/2024.
//

#import <IronSource/IronSource.h>
#import <IronSource/ISAdapterAdDelegate.h>
#import "LoopMeUnitedSDK/LoopMeSDK.h"
#import <IronSourceDemoApp-Swift.h>
#import <objc/runtime.h>
#import "ISLoopmeCustomBanner.h"
#import "ISLoopmeCustomInterstitial.h"
#import "ISLoopmeCustomRewardedVideo.h"
#import <LoopMeUnitedSDK/LoopMeAdDisplayControllerNormal.h>



//MARK: - IronSource
@implementation IronSource (loadInterstitial)

//Interstitial + Rewarded
+(void)swizzle_loadInterstitial {
    [IronSource swizzle_loadInterstitial];
    [[LegacyManger shared] logEventForCall: nil withText:@"Load (Adapter)" adType: nil];
}

+(void)swizzle_loadRewardedVideo {
    [IronSource swizzle_loadRewardedVideo];
    [[LegacyManger shared] logEventForCall: nil withText:@"Load (Adapter)" adType: nil];
}

//Banner
+(void)swizzle_loadBannerWithViewController:(UIViewController *)viewController size:(ISBannerSize *)size{
    [IronSource swizzle_loadBannerWithViewController: viewController size: size];
    [[LegacyManger shared] logEventForCall: nil withText:@"Load (Adapter)" adType: nil];
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];

        // Swizzle loadInterstitial
        Method loadInterstitialOriginal = class_getClassMethod(class, @selector(loadInterstitial));
        Method loadInterstitialSwizzle = class_getClassMethod(class, @selector(swizzle_loadInterstitial));
        method_exchangeImplementations(loadInterstitialOriginal, loadInterstitialSwizzle);
        
        // Swizzle loadRewardedVideo
        Method loadRewardedVideoOriginal = class_getClassMethod(class, @selector(loadRewardedVideo));
        Method loadRewardedVideSwizzle = class_getClassMethod(class, @selector(swizzle_loadRewardedVideo));
        method_exchangeImplementations(loadRewardedVideoOriginal, loadRewardedVideSwizzle);
        
        // Swizzle loadBannerWithViewController:
        Method loadBannerOrignal = class_getClassMethod(class, @selector(loadBannerWithViewController: size:));
        Method loadBannerSwizzle = class_getClassMethod(class, @selector((swizzle_loadBannerWithViewController:size:)));
        method_exchangeImplementations(loadBannerOrignal, loadBannerSwizzle);
        
    });
}
@end

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

//ISLoopmeCustomInterstitial
@implementation ISLoopmeCustomInterstitial (Swizzling)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];

        // Swizzle loopMeInterstitialDidLoadAd:
        SEL originalDidLoadSelector = @selector(loopMeInterstitialDidLoadAd:);
        SEL swizzledDidLoadSelector = @selector(swizzle_loopMeInterstitialDidLoadAd:);
        [self swizzleMethodForClass:class originalSelector:originalDidLoadSelector swizzledSelector:swizzledDidLoadSelector];

        // Swizzle loopMeInterstitial:didFailToLoadAdWithError:
        SEL originalDidFailSelector = @selector(loopMeInterstitial:didFailToLoadAdWithError:);
        SEL swizzledDidFailSelector = @selector(swizzle_loopMeInterstitial:didFailToLoadAdWithError:);
        [self swizzleMethodForClass:class originalSelector:originalDidFailSelector swizzledSelector:swizzledDidFailSelector];
    });
}

+ (void)swizzleMethodForClass:(Class)class originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

    BOOL didAddMethod = class_addMethod(class,
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

- (void)swizzle_loopMeInterstitialDidLoadAd:(LoopMeInterstitial *)interstitial {
    [self swizzle_loopMeInterstitialDidLoadAd:interstitial];
    [[LegacyManger shared] logEventForCall:nil withText:@"Did Load (Adapter)" adType: nil];
}

- (void)swizzle_loopMeInterstitial:(LoopMeInterstitial *)interstitial didFailToLoadAdWithError:(NSError *)error {
    [self swizzle_loopMeInterstitial:interstitial didFailToLoadAdWithError:error];
    [[LegacyManger shared] logEventForCall:nil withText:@"Did Fail (Adapter)" adType: nil];
}

@end


//ISLoopmeCustomBanner
@implementation ISLoopmeCustomBanner (Swizzling)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];

        // Swizzle loopMeAdViewDidLoadAd:
        SEL originalDidLoadSelector = @selector(loopMeAdViewDidLoadAd:);
        SEL swizzledDidLoadSelector = @selector(swizzle_loopMeAdViewDidLoadAd:);
        [self swizzleMethodForClass:class originalSelector:originalDidLoadSelector swizzledSelector:swizzledDidLoadSelector];
        
        // Swizzle loopMeAdView:didFailToLoadAdWithError:
        SEL originalDidFailSelector = @selector(loopMeAdView:didFailToLoadAdWithError:);
        SEL swizzledDidFailSelector = @selector(swizzle_loopMeAdView:didFailToLoadAdWithError:);
        [self swizzleMethodForClass:class originalSelector:originalDidFailSelector swizzledSelector:swizzledDidFailSelector];
    });
}

+ (void)swizzleMethodForClass:(Class)class originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

    BOOL didAddMethod = class_addMethod(class,
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

- (void)swizzle_loopMeAdViewDidLoadAd:(LoopMeAdView *)banner {
    [self swizzle_loopMeAdViewDidLoadAd:banner];
    [[LegacyManger shared] logEventForCall:nil withText:@"Did Load (Adapter)" adType: nil];
}

- (void)swizzle_loopMeAdView:(LoopMeAdView *)adView didFailToLoadAdWithError:(NSError *)error {
    [self swizzle_loopMeAdView:adView didFailToLoadAdWithError:error];
    [[LegacyManger shared] logEventForCall:nil withText:@"Did Fail (Adapter)" adType: nil];
}

@end

//MARK: ISLoopmeCustomRewardedVideo
@implementation ISLoopmeCustomRewardedVideo (Swizzling)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];

        // Swizzle loopMeInterstitialDidLoadAd:
        SEL originalDidLoadSelector = @selector(loopMeInterstitialDidLoadAd:);
        SEL swizzledDidLoadSelector = @selector(swizzle_loopMeInterstitialDidLoadAd:);
        [self swizzleMethodForClass:class originalSelector:originalDidLoadSelector swizzledSelector:swizzledDidLoadSelector];

        // Swizzle loopMeInterstitial:didFailToLoadAdWithError:
        SEL originalDidFailSelector = @selector(loopMeInterstitial:didFailToLoadAdWithError:);
        SEL swizzledDidFailSelector = @selector(swizzle_loopMeInterstitial:didFailToLoadAdWithError:);
        [self swizzleMethodForClass:class originalSelector:originalDidFailSelector swizzledSelector:swizzledDidFailSelector];
    });
}

+ (void)swizzleMethodForClass:(Class)class originalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);

    BOOL didAddMethod = class_addMethod(class,
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

- (void)swizzle_loopMeInterstitialDidLoadAd:(LoopMeInterstitial *)interstitial {
    [self swizzle_loopMeInterstitialDidLoadAd:interstitial];
    [[LegacyManger shared] logEventForCall:nil withText:@"Did Load (Adapter)" adType: nil];
}

- (void)swizzle_loopMeInterstitial:(LoopMeInterstitial *)interstitial didFailToLoadAdWithError:(NSError *)error {
    [self swizzle_loopMeInterstitial:interstitial didFailToLoadAdWithError:error];
    [[LegacyManger shared] logEventForCall:nil withText:@"Did Fail (Adapter)" adType: nil];
}

@end
