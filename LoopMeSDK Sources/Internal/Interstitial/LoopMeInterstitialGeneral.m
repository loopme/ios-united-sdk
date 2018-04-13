//
//  LoopMeInterstitial.m
//  LoopMeSDK
//
//  Created by Dmitriy Lihachov on 6/21/12.
//  Copyright (c) 2012 LoopMe. All rights reserved.
//

#import "LoopMeAdConfiguration.h"
#import "LoopMeDefinitions.h"
#import "LoopMeInterstitialGeneral.h"
#import "LoopMeAdManager.h"
#import "LoopMeTargeting.h"
#import "LoopMeGeoLocationProvider.h"
#import "LoopMeAdDisplayControllerNormal.h"
#import "LoopMeVPAIDAdDisplayController.h"
#import "LoopMeInterstitialViewController.h"
#import "LoopMeVPAIDError.h"
#import "LoopMeError.h"
#import "LoopMeLogging.h"
#import "LoopMeGlobalSettings.h"
#import "LoopMeErrorEventSender.h"
#import "LoopMeAnalyticsProvider.h"

const NSInteger kLoopMeRequestTimeout = 180;

@interface LoopMeInterstitialGeneral ()
<
    LoopMeAdManagerDelegate,
    LoopMeAdDisplayControllerDelegate,
    LoopMeInterstitialViewControllerDelegate
>
@property (nonatomic, assign, getter = isLoading) BOOL loading;
@property (nonatomic, assign, getter = isReady) BOOL ready;
@property (nonatomic, weak) LoopMeAdConfiguration *adConfiguration;
@property (nonatomic, strong) LoopMeAdManager *adManager;
@property (nonatomic, strong) LoopMeAdDisplayControllerNormal *adDisplayController;
@property (nonatomic, strong) LoopMeVPAIDAdDisplayController *adDisplayControllerVPAID;
@property (nonatomic, strong) LoopMeInterstitialViewController *adInterstitialViewController;
@property (nonatomic, assign) LoopMeAdType preferredAdTypes;
@property (nonatomic, strong) NSTimer *timeoutTimer;

@end

@implementation LoopMeInterstitialGeneral

#pragma mark - Life Cycle

- (void)dealloc {
    if (self.adInterstitialViewController.presentingViewController) {
        [self.adInterstitialViewController.presentingViewController
         dismissViewControllerAnimated:NO completion:nil];
    }
    //    [self unRegisterObserver];
    [_adManager invalidateTimers];
    
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeVPAID) {
        [_adDisplayController stopHandlingRequests];
    } else {
        [_adDisplayControllerVPAID stopHandlingRequests];
    }
    
    _adDisplayController.delegate = nil;
    _adDisplayControllerVPAID.delegate = nil;
}

- (instancetype)initWithAppKey:(NSString *)appKey
                      delegate:(id<LoopMeInterstitialGeneralDelegate>)delegate {
    return [self initWithAppKey:appKey preferredAdTypes:LoopMeAdTypeAll delegate:delegate];
}

- (instancetype)initWithAppKey:(NSString *)appKey
              preferredAdTypes:(LoopMeAdType)adTypes
                      delegate:(id<LoopMeInterstitialGeneralDelegate>)delegate {
    if (self = [super init]) {
        _appKey = [appKey copy];
        _delegate = delegate;
        _adManager = [[LoopMeAdManager alloc] initWithDelegate:self];
        _preferredAdTypes = adTypes;
        
        self.adDisplayController = [[LoopMeAdDisplayControllerNormal alloc] initWithDelegate:self];
        self.adDisplayController.isInterstitial = YES;
        
        self.adDisplayControllerVPAID = [[LoopMeVPAIDAdDisplayController alloc] initWithDelegate:self];
        self.adDisplayControllerVPAID.isInterstitial = YES;
        
        _adInterstitialViewController = [[LoopMeInterstitialViewController alloc] init];
        _adInterstitialViewController.delegate = self;
        LoopMeLogInfo(@"Interstitial is initialized with appKey %@", appKey);
        
        [LoopMeAnalyticsProvider sharedInstance];
    }
    return self;
}

- (void)setDoNotLoadVideoWithoutWiFi:(BOOL)doNotLoadVideoWithoutWiFi {
    [LoopMeGlobalSettings sharedInstance].doNotLoadVideoWithoutWiFi = doNotLoadVideoWithoutWiFi;
}

#pragma mark - Class Methods

+ (LoopMeInterstitialGeneral *)interstitialWithAppKey:(NSString *)appKey
                                     preferredAdTypes:(LoopMeAdType)adTypes
                                      delegate:(id<LoopMeInterstitialGeneralDelegate>)delegate {
    return [[LoopMeInterstitialGeneral alloc] initWithAppKey:appKey preferredAdTypes:adTypes delegate:delegate];
}

#pragma mark - Private

- (void)unRegisterObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)registerObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)willResignActive:(NSNotification *)n {
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeVPAID) {
        self.adDisplayController.visible = NO;
    } else {
        self.adDisplayControllerVPAID.visible = NO;
    }
}

- (void)didBecomeActive:(NSNotification *)n {
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeVPAID) {
        self.adDisplayController.visible = YES;
    } else {
        self.adDisplayControllerVPAID.visible = YES;
    }
}

- (void)failedLoadingAdWithError:(NSError *)error {
    self.loading = NO;
    self.ready = NO;
    
    if (self.adConfiguration.creativeType == LoopMeCreativeTypeVPAID) {
        [self.adDisplayControllerVPAID.vastEventTracker trackError:error.code];
    }
    
    [self invalidateTimer];
    if ([self.delegate respondsToSelector:@selector(loopMeInterstitial:didFailToLoadAdWithError:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate loopMeInterstitial:self didFailToLoadAdWithError:error];
        });
    }
}

- (void)timeOut {
    [LoopMeErrorEventSender sendError:LoopMeEventErrorTypeServer errorMessage:@"Time out" appkey:self.appKey];
    
    //-------NORMAL----
    [self.adDisplayController stopHandlingRequests];
    [self failedLoadingAdWithError:[LoopMeError errorForStatusCode:LoopMeErrorCodeHTMLRequestTimeOut]];
    //------VPAID-------
    [self.adDisplayControllerVPAID stopHandlingRequests];
    [self failedLoadingAdWithError:[LoopMeVPAIDError errorForStatusCode:LoopMeVPAIDErrorCodeUndefined]];
}

- (void)invalidateTimer {
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
}

//--------------------VPAID----------------
- (void)startAd {
    //    [self.adDisplayControllerVPAID layoutSubviews];
    [self.adConfiguration.eventTracker trackEvent:LoopMeVASTEventTypeLinearCreativeView];
    [self.adDisplayControllerVPAID startAd];
}
//-----------------------------
#pragma mark - Public Mehtods

- (void)setServerBaseURL:(NSURL *)URL {
    self.adManager.testServerBaseURL = URL;
}

- (void)loadAd {
    [self loadAdWithTargeting:nil];
}

- (void)loadAdWithTargeting:(LoopMeTargeting *)targeting {
    [self loadAdWithTargeting:targeting integrationType:@"normal"];
}

- (void)loadAdWithTargeting:(LoopMeTargeting *)targeting integrationType:(NSString *)integrationType {
    if (self.isLoading) {
        LoopMeLogInfo(@"Wait for previous loading ad process finish");
        return;
    }
    if (self.isReady) {
        LoopMeLogInfo(@"Ad already loaded and ready to be displayed");
        return;
    }
    [self registerObserver];
    self.loading = YES;
    self.ready = NO;
    self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:kLoopMeRequestTimeout target:self selector:@selector(timeOut) userInfo:nil repeats:NO];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.adManager loadAdWithAppKey:self.appKey targeting:targeting integrationType:integrationType adSpotSize:[[UIApplication sharedApplication] keyWindow].bounds.size adSpot:self preferredAdTypes:self.preferredAdTypes];
    });
}

- (void)showFromViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (!self.isReady) {
        LoopMeLogInfo(@"Ad isn't ready to be displayed");
        [LoopMeErrorEventSender sendError:LoopMeEventErrorTypeCustom errorMessage:@"Ad isn't ready to be displayed" appkey:self.appKey];
        return;
    }
    
    if (self.adInterstitialViewController.presentingViewController) {
        LoopMeLogInfo(@"Ad has already displayed");
        [LoopMeErrorEventSender sendError:LoopMeEventErrorTypeCustom errorMessage:@"Ad has already displayed" appkey:self.appKey];
        return;
    }
    
    LoopMeLogDebug(@"Interstitial ad will appear");
    if ([self.delegate respondsToSelector:@selector(loopMeInterstitialWillAppear:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate loopMeInterstitialWillAppear:self];
        });
    }
    [self.adManager invalidateTimers];
    [self.adInterstitialViewController setOrientation:self.adConfiguration.orientation];
    [self.adInterstitialViewController setAllowOrientationChange:self.adConfiguration.allowOrientationChange];
    
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeVPAID) {
        [self.adDisplayController displayAd];
        self.adDisplayController.visible = YES;
    } else {
        [self.adDisplayControllerVPAID displayAd];
        self.adDisplayControllerVPAID.visible = YES;
    }
    
    [viewController presentViewController:self.adInterstitialViewController animated:animated completion:^{
        
        if (self.adConfiguration.creativeType != LoopMeCreativeTypeVPAID) {
            [self.adDisplayController layoutSubviews];
        } else {
            [self startAd];
        }
        
        LoopMeLogDebug(@"Interstitial ad did appear");
        if ([self.delegate respondsToSelector:@selector(loopMeInterstitialDidAppear:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate loopMeInterstitialDidAppear:self];
            });
        }
    }];
}

- (void)dismissAnimated:(BOOL)animated {
    if (!self.adInterstitialViewController.presentingViewController) {
        return;
    }
    self.ready = NO;
    LoopMeLogDebug(@"Interstitial ad will disappear");
    if ([self.delegate respondsToSelector:@selector(loopMeInterstitialWillDisappear:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate loopMeInterstitialWillDisappear:self];
        });
    }
    
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeVPAID) {
        [self.adDisplayController closeAd];
    } else {
        [self.adDisplayControllerVPAID closeAd];
    }
    [self unRegisterObserver];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.adInterstitialViewController.presentingViewController dismissViewControllerAnimated:animated completion:^{
            LoopMeLogDebug(@"Interstitial ad did disappear");
            if ([self.delegate respondsToSelector:@selector(loopMeInterstitialDidDisappear:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate loopMeInterstitialDidDisappear:self];
                });
            }
        }];
    });
}

#pragma mark - LoopMeAdManagerDelegate

- (void)adManager:(LoopMeAdManager *)manager didReceiveAdConfiguration:(LoopMeAdConfiguration *)adConfiguration {
    if (!adConfiguration) {
        NSString *errorMessage = @"Could not process ad: interstitial format expected.";
        LoopMeLogDebug(errorMessage);
        NSError *error = [LoopMeError errorForStatusCode:LoopMeErrorCodeIncorrectFormat];
        [self failedLoadingAdWithError:error];
        return;
    }
    
    self.adConfiguration = adConfiguration;
    
    if ([LoopMeGlobalSettings sharedInstance].liveDebugEnabled ) {
        [LoopMeGlobalSettings sharedInstance].appKeyForLiveDebug = self.appKey;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (adConfiguration.creativeType != LoopMeCreativeTypeVPAID) {
            [[LoopMeGlobalSettings sharedInstance].adIds setObject:adConfiguration.adIdsForMOAT forKey:self.appKey];
            [self.adDisplayController setAdConfiguration:self.adConfiguration];
            [self.adDisplayController loadAdConfiguration];
        } else {
            [self.adDisplayControllerVPAID setAdConfiguration:self.adConfiguration];
        }
    });
}

- (void)adManagerDidReceiveAd:(LoopMeAdManager *)manager {
    if (self.adConfiguration.creativeType == LoopMeCreativeTypeVPAID) {
        if (!self.adConfiguration) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.adDisplayControllerVPAID loadAdConfiguration];
        });
    }
}

- (void)adManager:(LoopMeAdManager *)manager didFailToLoadAdWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self failedLoadingAdWithError:error];
    });
}

- (void)adManagerDidExpireAd:(LoopMeAdManager *)manager {
    self.ready = NO;
    if ([self.delegate respondsToSelector:@selector(loopMeInterstitialDidExpire:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate loopMeInterstitialDidExpire:self];
        });
    }
}

#pragma mark - LoopMeInterstitialViewControllerDelegate

- (void)viewWillTransitionToSize:(CGSize)size {
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeVPAID) {
        [self.adDisplayController layoutSubviewsToFrame:CGRectMake(0, 0, size.width, size.height)];
        [self.adDisplayController resizeTo:size];
    } else {
        [self.adDisplayControllerVPAID layoutSubviewsToFrame:CGRectMake(0, 0, size.width, size.height)];
    }
}

#pragma mark - LoopMeAdDisplayControllerDelegate

- (UIViewController *)viewControllerForPresentation {
    return self.adInterstitialViewController;
}

- (UIView *)containerView {
    return self.adInterstitialViewController.view;
}

- (void)adDisplayControllerDidFinishLoadingAd:(LoopMeAdDisplayControllerNormal *)adDisplayController {
    if (self.isReady) {
        return;
    }
    self.loading = NO;
    self.ready = YES;
    [self invalidateTimer];
    if ([self.delegate respondsToSelector:@selector(loopMeInterstitialDidLoadAd:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate loopMeInterstitialDidLoadAd:self];
        });
    }
}

- (void)adDisplayController:(LoopMeAdDisplayControllerNormal *)adDisplayController didFailToLoadAdWithError:(NSError *)error {
    [self failedLoadingAdWithError:error];
}

- (void)adDisplayControllerDidReceiveTap:(LoopMeAdDisplayControllerNormal *)adDisplayController {
    if ([self.delegate respondsToSelector:@selector(loopMeInterstitialDidReceiveTap:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate loopMeInterstitialDidReceiveTap:self];
        });
    }
}

- (void)adDisplayControllerWillLeaveApplication:(LoopMeAdDisplayControllerNormal *)adDisplayController {
    if ([self.delegate respondsToSelector:@selector(loopMeInterstitialWillLeaveApplication:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate loopMeInterstitialWillLeaveApplication:self];
        });
    }
}

- (void)adDisplayControllerVideoDidReachEnd:(LoopMeAdDisplayControllerNormal *)adDisplayController {
    if ([self.delegate respondsToSelector:@selector(loopMeInterstitialVideoDidReachEnd:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate loopMeInterstitialVideoDidReachEnd:self];
        });
    }
}

- (void)adDisplayControllerWillExpandAd:(LoopMeAdDisplayControllerNormal *)adDisplayController {
    
}

- (void)adDisplayControllerShouldCloseAd:(LoopMeAdDisplayControllerNormal *)adDisplayController {
    [self dismissAnimated:NO];
    
    LoopMeAdConfiguration *c = [[self.adManager performSelector:@selector(communicator)] performSelector:@selector(configuration)];
    c.trackingLinks = nil;
    c.assetLinks = nil;
}

- (void)adDisplayControllerDidDismissModal:(LoopMeAdDisplayControllerNormal *)adDisplayController {
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeVPAID) {
        self.adDisplayController.visible = YES;
    } else {
        self.adDisplayControllerVPAID.visible = YES;
    }
}

- (void)adDisplayControllerWillCollapse:(LoopMeAdDisplayControllerNormal *)adDisplayController {
    
}

@end
