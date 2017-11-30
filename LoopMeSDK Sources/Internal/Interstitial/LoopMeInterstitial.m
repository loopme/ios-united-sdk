//
//  LoopMeInterstitial.m
//  LoopMeSDK
//
//  Created by Dmitriy Lihachov on 6/21/12.
//  Copyright (c) 2012 LoopMe. All rights reserved.
//

#import "LoopMeDefinitions.h"
#import "LoopMeInterstitial.h"
#import "LoopMeInterstitialGeneral.h"
#import "LoopMeTargeting.h"
#import "LoopMeGeoLocationProvider.h"
#import "LoopMeError.h"
#import "LoopMeLogging.h"
#import "LoopMeGlobalSettings.h"
#import "LoopMeErrorEventSender.h"
#import "LoopMeAnalyticsProvider.h"

static NSString * const kLoopMeIntegrationTypeNormal = @"normal";
static const NSTimeInterval kLoopMeTimeToReload = 900;

@interface LoopMeInterstitial ()
<
    LoopMeInterstitialGeneralDelegate
>
{
    BOOL _autoLoadingEnabled;
}

@property (nonatomic, assign, getter = isLoading) BOOL loading;
@property (nonatomic, assign, getter = isReady) BOOL ready;
@property (nonatomic, strong) NSString *integrationType;

@property (nonatomic) LoopMeInterstitialGeneral *interstitial1;
@property (nonatomic) LoopMeInterstitialGeneral *interstitial2;
@property (nonatomic) LoopMeTargeting *targeting;

@property (nonatomic, assign, getter=isShown) BOOL shown;

@property (nonatomic, assign) NSInteger showCount;
@property (nonatomic, assign) NSInteger failCount;
@property (nonatomic, strong) NSTimer *timerToReload;

@end

@implementation LoopMeInterstitial

#pragma mark - Life Cycle

- (void)dealloc {
    self.interstitial1 = nil;
    self.interstitial2 = nil;
}

- (instancetype)initWithAppKey:(NSString *)appKey
                      delegate:(id<LoopMeInterstitialDelegate>)delegate {
    
    if (self = [super init]) {
        _interstitial1 = [LoopMeInterstitialGeneral interstitialWithAppKey:appKey delegate:self];
        _interstitial2 = [LoopMeInterstitialGeneral interstitialWithAppKey:appKey delegate:self];
        _delegate = delegate;
        _autoLoadingEnabled = YES;
        _failCount = 0;
    }
    return self;
}

- (void)setDoNotLoadVideoWithoutWiFi:(BOOL)doNotLoadVideoWithoutWiFi {
    [LoopMeGlobalSettings sharedInstance].doNotLoadVideoWithoutWiFi = doNotLoadVideoWithoutWiFi;
}

- (void)setAutoLoadingEnabled:(BOOL)autoLoadingEnabled {
    _autoLoadingEnabled = autoLoadingEnabled;
    self.failCount = 0;
}

#pragma mark - Class Methods

+ (instancetype)interstitialWithAppKey:(NSString *)appKey
                                             delegate:(id<LoopMeInterstitialDelegate>)delegate {
    return [[LoopMeInterstitial alloc] initWithAppKey:appKey delegate:delegate];
}

#pragma mark - Private

- (void)reload {
    self.failCount = 0;
    [self.timerToReload invalidate];
    self.timerToReload = nil;
    [self loadAdWithTargeting:self.targeting integrationType:kLoopMeIntegrationTypeNormal];
}

#pragma mark - Public Mehtods

- (NSString *)appKey {
    return self.interstitial1.appKey ? self.interstitial1.appKey : self.interstitial2.appKey;
}

- (BOOL)isAutoLoadingEnabled {
    BOOL responseAutoLoading = [[NSUserDefaults standardUserDefaults] boolForKey:LOOPME_USERDEFAULTS_KEY_AUTOLOADING];
    return (_autoLoadingEnabled && responseAutoLoading);
}

- (void)loadAd {
    [self loadAdWithTargeting:nil];
}

- (void)loadAdWithTargeting:(LoopMeTargeting *)targeting {
    self.targeting = targeting;
    [self loadAdWithTargeting:targeting integrationType:kLoopMeIntegrationTypeNormal];
}

- (void)loadAdWithTargeting:(LoopMeTargeting *)targeting integrationType:(NSString *)integrationType {
    if (self.failCount >= 5) {
        return;
    }
    
    self.integrationType = integrationType;
    [self.interstitial1 loadAdWithTargeting:targeting integrationType:self.integrationType];
    if (self.isAutoLoadingEnabled) {
        [self.interstitial2 loadAdWithTargeting:targeting integrationType:self.integrationType];
    }
}

- (void)showFromViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.isShown) {
        LoopMeLogDebug(@"Interstitial has already shown");
        return;
    }
    self.shown = YES;
    LoopMeInterstitialGeneral *interstitial = self.interstitial1.isReady ? self.interstitial1 : self.interstitial2;
    [interstitial showFromViewController:viewController animated:animated];
}

- (void)dismissAnimated:(BOOL)animated {
    self.shown = NO;
    [self.interstitial1 dismissAnimated:animated];
    if (self.isAutoLoadingEnabled) {
        [self.interstitial2 dismissAnimated:animated];
    }
}

- (BOOL)isReady {
    if (self.isAutoLoadingEnabled) {
        return self.interstitial1.isReady || self.interstitial2.isReady;
    } else {
        return self.interstitial1.isReady;
    }
}

#pragma mark - LoopMeInterstitialDelegate

- (void)loopMeInterstitialDidAppear:(LoopMeInterstitialGeneral *)interstitial {
    if ([self.delegate respondsToSelector:@selector(loopMeInterstitialDidAppear:)]) {
        [self.delegate loopMeInterstitialDidAppear:self];
    }
}

- (void)loopMeInterstitialDidExpire:(LoopMeInterstitialGeneral *)interstitial {
    
    if (self.isAutoLoadingEnabled) {
        [interstitial loadAdWithTargeting:self.targeting integrationType:self.integrationType];
    }
    
    if (!self.isAutoLoadingEnabled || !self.isReady) {
        if ([self.delegate respondsToSelector:@selector(loopMeInterstitialDidExpire:)]) {
            [self.delegate loopMeInterstitialDidExpire:self];
        }
    }
}

- (void)loopMeInterstitialDidLoadAd:(LoopMeInterstitialGeneral *)interstitial {
    self.failCount = 0;
    if ([self.delegate respondsToSelector:@selector(loopMeInterstitialDidLoadAd:)]) {
        [self.delegate loopMeInterstitialDidLoadAd:self];
    }
}

- (void)loopMeInterstitialWillAppear:(LoopMeInterstitialGeneral *)interstitial {
    if ([self.delegate respondsToSelector:@selector(loopMeInterstitialWillAppear:)]) {
        [self.delegate loopMeInterstitialWillAppear:self];
    }
}

- (void)loopMeInterstitialDidDisappear:(LoopMeInterstitialGeneral *)interstitial {
    
    self.shown = NO;
    
    if ([self.delegate respondsToSelector:@selector(loopMeInterstitialDidDisappear:)]) {
        [self.delegate loopMeInterstitialDidDisappear:self];
    }
    
    if (self.isAutoLoadingEnabled && self.failCount < 5) {
        [self loadAdWithTargeting:self.targeting integrationType:self.integrationType];
    
        if (self.isReady) {
            if ([self.delegate respondsToSelector:@selector(loopMeInterstitialDidLoadAd:)]) {
                [self.delegate loopMeInterstitialDidLoadAd:self];
            }
        }
    }
}

- (void)loopMeInterstitialDidReceiveTap:(LoopMeInterstitialGeneral *)interstitial {
    if ([self.delegate respondsToSelector:@selector(loopMeInterstitialDidReceiveTap:)]) {
        [self.delegate loopMeInterstitialDidReceiveTap:self];
    }
}

- (void)loopMeInterstitialWillDisappear:(LoopMeInterstitialGeneral *)interstitial {
    if ([self.delegate respondsToSelector:@selector(loopMeInterstitialWillDisappear:)]) {
        [self.delegate loopMeInterstitialWillDisappear:self];
    }
}

- (void)loopMeInterstitialVideoDidReachEnd:(LoopMeInterstitialGeneral *)interstitial {
    if ([self.delegate respondsToSelector:@selector(loopMeInterstitialVideoDidReachEnd:)]) {
        [self.delegate loopMeInterstitialVideoDidReachEnd:self];
    }
}

- (void)loopMeInterstitialWillLeaveApplication:(LoopMeInterstitialGeneral *)interstitial {
    if ([self.delegate respondsToSelector:@selector(loopMeInterstitialWillLeaveApplication:)]) {
        [self.delegate loopMeInterstitialWillLeaveApplication:self];
    }
}

- (void)loopMeInterstitial:(LoopMeInterstitialGeneral *)interstitial didFailToLoadAdWithError:(NSError *)error {
    
    if (self.isAutoLoadingEnabled) {
        if (self.timerToReload.isValid) {
            return;
        }
        if (self.failCount >= 5) {
            self.timerToReload = [NSTimer scheduledTimerWithTimeInterval:kLoopMeTimeToReload target:self selector:@selector(reload) userInfo:nil repeats:NO];
            if ([self.delegate respondsToSelector:@selector(loopMeInterstitial:didFailToLoadAdWithError:)]) {
                [self.delegate loopMeInterstitial:self didFailToLoadAdWithError:error];
            }
            return;
        }
        self.failCount += 1;
        [interstitial loadAdWithTargeting:self.targeting integrationType:self.integrationType];
    } else {
        if (!self.isReady) {
            if ([self.delegate respondsToSelector:@selector(loopMeInterstitial:didFailToLoadAdWithError:)]) {
                [self.delegate loopMeInterstitial:self didFailToLoadAdWithError:error];
            }
        }
    }
}


@end
