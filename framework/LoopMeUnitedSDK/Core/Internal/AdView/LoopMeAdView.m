//
//  Nativevideo.m
//  LoopMeSDK
//
//  Created by Kogda Bogdan on 2/13/15.
//  Copyright (c) 2012 LoopMe. All rights reserved.
//
#import <LoopMeUnitedSDK/LoopMeUnitedSDK-Swift.h>

#import "LoopMeAdView.h"
#import "LoopMeAdManager.h"
#import "LoopMeVPAIDAdDisplayController.h"
#import "LoopMeAdDisplayControllerNormal.h"
#import "LoopMeDefinitions.h"
#import "LoopMeVPAIDError.h"
#import "LoopMeError.h"
#import "LoopMeLogging.h"
#import "LoopMeMinimizedAdView.h"
#import "LoopMeMaximizedViewController.h"
#import "LoopMeGlobalSettings.h"
#import "LoopMeErrorEventSender.h"
#import "LoopMeGDPRTools.h"
#import "LoopMeSDK.h"
#import <StoreKit/StoreKit.h>


@interface LoopMeAdView ()
<
    LoopMeAdManagerDelegate,
    LoopMeAdDisplayControllerDelegate,
    LoopMeMinimizedAdViewDelegate,
    LoopMeMaximizedViewControllerDelegate
>
@property (nonatomic, strong) LoopMeAdManager *adManager;
@property (nonatomic, strong) LoopMeAdDisplayControllerNormal *adDisplayController;
@property (nonatomic, strong) LoopMeVPAIDAdDisplayController *adDisplayControllerVPAID;
@property (nonatomic, strong) LoopMeMinimizedAdView *minimizedView;
@property (nonatomic, strong) LoopMeMaximizedViewController *maximizedController;
@property (nonatomic, strong) NSString *appKey;
@property (nonatomic, assign, getter = isLoading) BOOL loading;
@property (nonatomic, assign, getter = isReady) BOOL ready;
@property (nonatomic, assign, getter = isMinimized) BOOL minimized;
@property (nonatomic, assign, getter = isNeedsToBeDisplayedWhenReady) BOOL needsToBeDisplayedWhenReady;
@property (nonatomic, strong) NSTimer *timeoutTimer;
@property (nonatomic, weak) LoopMeAdConfiguration *adConfiguration;

@property (nonatomic, strong) NSLayoutConstraint *expandedWidth;
@property (nonatomic, strong) NSLayoutConstraint *expandedHeight;
@property (nonatomic, strong) SKAdImpression *skAdImpression;

/*
 * Update webView "visible" state is required on JS first time when ad appears on the screen,
 * further, we're ommiting sending "webView" states to JS but managing video ad. playback in-SDK
 */
@property (nonatomic, assign, getter = isVisibilityUpdated) BOOL visibilityUpdated;
@end

// TODO: This class takes to much responsibility - refactor
@implementation LoopMeAdView

#pragma mark - Initialization

- (void)dealloc {
    [self unRegisterObservers];
    [_minimizedView removeFromSuperview];
    [_maximizedController hide];
    [_adDisplayController stopHandlingRequests];
    [_adDisplayControllerVPAID stopHandlingRequests];
}

- (instancetype)initWithAppKey: (NSString *)appKey
                         frame: (CGRect)frame
                    scrollView: (UIScrollView *)scrollView
              preferredAdTypes: (LoopMeAdType)preferredAdTypes
                      delegate: (id<LoopMeAdViewDelegate>)delegate {
    self = [super init];
    if (self) {
        self.adConfiguration.placement = @"banner";
        if (![[LoopMeSDK shared] isReady]) {
            LoopMeLogError(@"SDK is not inited");
            return nil;
        }
        
        if (!appKey) {
            LoopMeLogError(@"AppKey cann't be nil");
            return nil;
        }
        
        if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
            LoopMeLogDebug(@"Block iOS versions less then 10.0");
            return nil;
        }
        
        _appKey = appKey;
        _delegate = delegate;
        _preferredAdTypes = preferredAdTypes;
        _adManager = [[LoopMeAdManager alloc] initWithDelegate: self];
        _adDisplayController = [[LoopMeAdDisplayControllerNormal alloc] initWithDelegate: self];
        _adDisplayControllerVPAID = [[LoopMeVPAIDAdDisplayController alloc] initWithDelegate: self];
        _maximizedController = [[LoopMeMaximizedViewController alloc] initWithDelegate: self];
        _maximizedController.modalPresentationStyle = UIModalPresentationFullScreen;
        _scrollView = scrollView;
        self.frame = frame;
        [self addConstraint: [self.widthAnchor constraintEqualToConstant: frame.size.width]];
        [self addConstraint: [self.heightAnchor constraintEqualToConstant: frame.size.height]];
        self.backgroundColor = [UIColor clearColor];
        [self registerObservers];
        LoopMeLogInfo(@"Ad view initialized with appKey: %@", appKey);
    }
    return self;
}

- (void)setMinimizedModeEnabled: (BOOL)minimizedModeEnabled {
    if (_minimizedModeEnabled == minimizedModeEnabled) {
        return ;
    }
    _minimizedModeEnabled = minimizedModeEnabled;
    if (!_minimizedModeEnabled) {
        [self removeMinimizedView];
        return ;
    }
    _minimizedView = [[LoopMeMinimizedAdView alloc] initWithDelegate: self];
    _minimizedView.backgroundColor = [UIColor clearColor];
    _minimizedView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [[UIApplication sharedApplication].keyWindow addSubview: _minimizedView];
}

- (void)setDoNotLoadVideoWithoutWiFi: (BOOL)doNotLoadVideoWithoutWiFi {
    [LoopMeGlobalSettings sharedInstance].doNotLoadVideoWithoutWiFi = doNotLoadVideoWithoutWiFi;
}

- (void)expand {
    BOOL isMaximized = [self.maximizedController presentingViewController] != nil;
    if (isMaximized) {
        return;
    }
    if (self.adConfiguration.creativeType == LoopMeCreativeTypeMraid) {
        [self.adDisplayController setExpandProperties: self.adConfiguration];
        [self.adDisplayController setOrientationProperties: nil];
    }
    [self.maximizedController show];
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeVast) {
        [self.adDisplayController moveView: NO];
        [self.adDisplayController expandReporting];
    } else {
        [self.adDisplayControllerVPAID moveView: NO];
        [self.adDisplayControllerVPAID expandReporting];
    }
}

#pragma  mark - SkadNetwork func

- (void)startSKAdImpression {
    // Create an SKAdImpression instance
    if (@available(iOS 14.5, *)) {
        [SKAdNetwork startImpression: self.skAdImpression completionHandler: ^(NSError * _Nullable error) {
            if (error) {
                // TODO: send event to server
                NSLog(@"Error starting SKAdImpression: %@", error.localizedDescription);
            } else {
                NSLog(@"SKAdImpression started successfully");
            }
        }];
    }
}

- (void)endSKAdImpression {
    // Create an SKAdImpression instance
    if (@available(iOS 14.5, *)) {
        [SKAdNetwork endImpression: self.skAdImpression completionHandler: ^(NSError * _Nullable error) {
            if (error) {
                // TODO: send event to server
                NSLog(@"Error starting SKAdImpression: %@", error.localizedDescription);
            } else {
                NSLog(@"SKAdImpression ended successfully");
            }
        }];
    }
}

#pragma mark - Class Methods

/// TODO: Remove it because of deprecation
+ (LoopMeAdView *)adViewWithAppKey: (NSString *)appKey
                             frame: (CGRect)frame
viewControllerForPresentationGDPRWindow: (UIViewController *)viewController
                          delegate: (id<LoopMeAdViewDelegate>)delegate __attribute__((deprecated("Use adViewWithAppKey:appkey:frame:delegate instead"))) {
    return [LoopMeAdView adViewWithAppKey: appKey frame: frame delegate: delegate];
};

/// TODO: Remove it because of deprecation
+ (LoopMeAdView *)adViewWithAppKey: (NSString *)appKey
                             frame: (CGRect)frame
viewControllerForPresentationGDPRWindow: (UIViewController *)viewController
                        scrollView: (UIScrollView *)scrollView
                          delegate: (id<LoopMeAdViewDelegate>)delegate __attribute__((deprecated("Use adViewWithAppKey:appkey:frame:scrollView:delegate instead"))) {
    return [LoopMeAdView adViewWithAppKey: appKey frame: frame scrollView: scrollView delegate: delegate];
};

+ (LoopMeAdView *)adViewWithAppKey: (NSString *)appKey
                             frame: (CGRect)frame
                        scrollView: (UIScrollView *)scrollView
                          delegate: (id<LoopMeAdViewDelegate>)delegate {
    return [[self alloc] initWithAppKey: appKey
                                  frame: frame
                             scrollView: scrollView
                       preferredAdTypes: LoopMeAdTypeAll
                               delegate: delegate];
}

+ (LoopMeAdView *)adViewWithAppKey: (NSString *)appKey
                             frame: (CGRect)frame
                          delegate: (id<LoopMeAdViewDelegate>)delegate {
    return [LoopMeAdView adViewWithAppKey: appKey
                                    frame: frame
                               scrollView: nil
                         preferredAdTypes: LoopMeAdTypeAll
                                 delegate: delegate];
}

+ (LoopMeAdView *)adViewWithAppKey: (NSString *)appKey
                             frame: (CGRect)frame
                        scrollView: (UIScrollView *)scrollView
                  preferredAdTypes: (LoopMeAdType)adTypes
                          delegate: (id<LoopMeAdViewDelegate>)delegate {
    return [[self alloc] initWithAppKey: appKey
                                  frame: frame
                             scrollView: scrollView
                       preferredAdTypes: adTypes
                               delegate: delegate];
}

+ (LoopMeAdView *)adViewWithAppKey: (NSString *)appKey
                             frame: (CGRect)frame
                  preferredAdTypes: (LoopMeAdType)preferredAdTypes
                          delegate: (id<LoopMeAdViewDelegate>)delegate {
    return [LoopMeAdView adViewWithAppKey: appKey
                                    frame: frame
                               scrollView: nil
                         preferredAdTypes: preferredAdTypes
                                 delegate: delegate];
}

#pragma mark - LifeCycle

- (void)willMoveToSuperview: (UIView *)newSuperview {
    [super willMoveToSuperview: newSuperview];
    if (!newSuperview) {
        [self closeAd];
        if ([self.delegate respondsToSelector: @selector(loopMeAdViewWillDisappear:)]) {
            [self.delegate loopMeAdViewWillDisappear: self];
        }
        return;
    }
    if (!self.isReady) {
        NSMutableDictionary *infoDictionary = [self.adConfiguration toDictionary];
        [infoDictionary setObject:@"LoopMeAdView" forKey:kErrorInfoClass];

        [LoopMeErrorEventSender sendError: LoopMeEventErrorTypeCustom
                             errorMessage: @"Banner added to view, but wasn't ready to be displayed"
                                     info: infoDictionary];
        self.needsToBeDisplayedWhenReady = YES;
    }
    if ([self.delegate respondsToSelector: @selector(loopMeAdViewWillAppear:)]) {
        [self.delegate loopMeAdViewWillAppear: self];
    }
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.superview && self.isReady) {
        [self performSelector: @selector(displayAd) withObject: nil afterDelay: 0.00];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}

#pragma mark - Observering

- (void)unRegisterObservers {
    [[NSNotificationCenter defaultCenter] removeObserver: self name: UIApplicationDidBecomeActiveNotification object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: UIApplicationWillResignActiveNotification object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: UIDeviceOrientationDidChangeNotification object: nil];
}

- (void)registerObservers {
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(didBecomeActive:)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(deviceOrientationDidChange:)
                                                 name: UIDeviceOrientationDidChangeNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(willResignActive:)
                                                 name: UIApplicationWillResignActiveNotification
                                               object: nil];
}

- (void)didBecomeActive: (NSNotification *)notification {
    if (self.superview) {
        self.visibilityUpdated = NO;
        [self updateVisibility];
    }
}

- (void)willResignActive: (NSNotification *)notification {
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeVast) {
        self.adDisplayController.visible = NO;
    } else {
        self.adDisplayControllerVPAID.visible = NO;
    }
    if ([self.maximizedController isBeingPresented]) {
        [self removeMaximizedView];
    }
}

- (void)deviceOrientationDidChange: (NSNotification *)notification {
    [self.minimizedView rotateToInterfaceOrientation: [UIApplication sharedApplication].statusBarOrientation animated: YES];
    [self.minimizedView adjustFrame];
}


#pragma mark - Public

- (void)setServerBaseURL: (NSURL *)URL {
    self.adManager.testServerBaseURL = URL;
}

- (void)loadAd {
    [self loadAdWithTargeting: nil integrationType: @"normal"];
}

- (void)loadAdWithTargeting: (LoopMeTargeting *)targeting {
    [self loadAdWithTargeting: targeting integrationType: @"normal"];
}

- (void)timeOut: (NSTimer *)timer {
    if (self.timeoutTimer != timer) {
        return ;
    }
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeVast) {
        [self.adDisplayController stopHandlingRequests];
    } else {
        [self.adDisplayControllerVPAID stopHandlingRequests];
    }
    [LoopMeErrorEventSender sendError: LoopMeEventErrorTypeServer
                         errorMessage: @"Time out"
                                 info:self.adConfiguration.toDictionary];
    [self failedLoadingAdWithError: [LoopMeError errorForStatusCode: LoopMeErrorCodeHTMLRequestTimeOut]];
}

- (void)invalidateTimer {
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
}

- (void)runTimeoutTimer {
    if (self.timeoutTimer) {
        [self invalidateTimer];
    }
    self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval: 180 target: self selector: @selector(timeOut:) userInfo: nil repeats: NO];
}

- (void)loadAdWithTargeting: (LoopMeTargeting *)targeting integrationType: (NSString *)integrationType {
    // self.adManager can be in loading state also
    // TODO: rethink this logic - we need to have only one source of truth
    if (self.isLoading || self.adManager.isLoading) {
        return LoopMeLogInfo(@"Wait for previous loading ad process finish");
    }
    if (self.isReady) {
        return LoopMeLogInfo(@"Ad already loaded and ready to be displayed");
    }
    self.ready = NO;
    self.loading = YES;
    [self runTimeoutTimer];
    [self.adManager loadAdWithAppKey: self.appKey
                           targeting: targeting
                     integrationType: integrationType
                          adSpotSize: self.containerView.bounds.size
                              adSpot: self
                    preferredAdTypes: self.preferredAdTypes
                          isRewarded: NO];
}

- (void)loadURL: (NSURL *)url {
    self.ready = NO;
    self.loading = YES;
    [self runTimeoutTimer];
    [self.adManager loadURL: url];
}

- (void)updateAdVisibilityInScrollView {
    if (!self.superview) {
        return;
    }
    if ([self.maximizedController isBeingPresented]) {
        self.adDisplayController.visibleNoJS = YES;
        return;
    }
    if (self.adDisplayController.destinationIsPresented) {
        return;
    }
    
    CGRect relativeToScrollViewAdRect = [self convertRect: self.bounds toView: self.scrollView];
    relativeToScrollViewAdRect.origin.y -= (self.scrollView.contentOffset.y);
    if (@available(iOS 11.0, *)) {
        CGRect visibleScrollViewRect = CGRectMake(
                                                  self.scrollView.contentOffset.x,
                                                  self.scrollView.adjustedContentInset.top,
                                                  self.scrollView.bounds.size.width,
                                                  self.scrollView.bounds.size.height - self.scrollView.adjustedContentInset.top - self.scrollView.adjustedContentInset.bottom);
        if (![self isRect: relativeToScrollViewAdRect outOfRect: visibleScrollViewRect]) {
            if (self.isMinimizedModeEnabled && self.minimizedView.superview) {
                [self updateAdVisibilityWhenScroll];
                [self minimize];
            }
        } else {
            [self toOriginalSize];
        }
        if (self.isMinimized) {
            return;
        }
        
        if ([self moreThenHalfOfRect: relativeToScrollViewAdRect visibleInRect: visibleScrollViewRect]) {
            [self updateAdVisibilityWhenScroll];
        } else {
            self.adDisplayController.visibleNoJS = NO;
            self.adDisplayControllerVPAID.visible = NO;
        }
    }
}

#pragma mark - Private

- (void)minimize {
    if (self.isMinimized || !(self.adDisplayController.isVisible || self.adDisplayControllerVPAID.isVisible)) {
        return ;
    }
    self.minimized = YES;
    [self.minimizedView show];
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeVast) {
        [self.adDisplayController moveView: YES];
    } else {
        [self.adDisplayControllerVPAID moveView: YES];
    }
}

- (void)toOriginalSize {
    if (!self.isMinimized) {
        return;
    }
    self.minimized = NO;
    [self.minimizedView hide];
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeVast) {
        [self.adDisplayController moveView: NO];
    } else {
        [self.adDisplayControllerVPAID moveView: NO];
    }
}

- (void)removeMinimizedView {
    [self.minimizedView removeFromSuperview];
    self.minimizedView = nil;
}

- (void)removeMaximizedView {
    [self.maximizedController hide];
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeVast) {
        [self.adDisplayController moveView: NO];
        [self.adDisplayController collapseReporting];
    } else {
        [self.adDisplayControllerVPAID moveView: NO];
        [self.adDisplayControllerVPAID collapseReporting];
    }
}

- (BOOL)moreThenHalfOfRect: (CGRect)rect visibleInRect: (CGRect)visibleRect {
    return (CGRectContainsPoint(visibleRect, CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))));
}

- (BOOL)isRect: (CGRect)rect outOfRect: (CGRect)visibleRect {
    return CGRectIntersectsRect(rect, visibleRect);
}

- (void)failedLoadingAdWithError: (NSError *)error {
    self.loading = NO;
    self.ready = NO;
    if (self.adConfiguration.creativeType == LoopMeCreativeTypeVast) {
        [self.adDisplayControllerVPAID.vastEventTracker trackErrorCode: error.code];
    }
    [self invalidateTimer];
    if ([self.delegate respondsToSelector :@selector(loopMeAdView:didFailToLoadAdWithError:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate loopMeAdView: self didFailToLoadAdWithError: error];
        });
    }
}

- (void)updateVisibility {
    if (self.scrollView) {
        [self updateAdVisibilityInScrollView];
        return;
    }
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeVast) {
        self.adDisplayController.visible = YES;
    } else {
        self.adDisplayControllerVPAID.visible = YES;
        [self.adDisplayControllerVPAID startAd];
    }
}

- (void)updateAdVisibilityWhenScroll {
    [self endSKAdImpression];
    if (!self.isVisibilityUpdated) {
        if (self.adConfiguration.creativeType != LoopMeCreativeTypeVast) {
            self.adDisplayController.visible = YES;
        } else {
            self.adDisplayControllerVPAID.visible = YES;
            [self.adDisplayControllerVPAID startAd];
        }
        self.visibilityUpdated = YES;
    } else {
        self.adDisplayController.visibleNoJS = YES;
        self.adDisplayControllerVPAID.visible = YES;
    }
}

- (void)closeAd {
    [self.minimizedView removeFromSuperview];
    [self.maximizedController hide];
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeVast) {
        [self.adDisplayController closeAd];
    } else {
        [self.adDisplayControllerVPAID closeAd];
    }
    self.ready = NO;
    self.loading = NO;
}

- (void)displayAd {
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeVast) {
        [self.adDisplayController displayAd];
    } else {
        [self.adDisplayControllerVPAID displayAd];
    }
    [self.adManager invalidateTimers];
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        return;
    }
    [self startSKAdImpression];
    [self.adDisplayControllerVPAID startAd];
    [self updateVisibility];
}

- (BOOL)isMaximizedControllerIsPresented {
    return self.maximizedController.isViewLoaded && self.maximizedController.view.window;
}

#pragma mark - LoopMeAdManagerDelegate

- (void)adManager: (LoopMeAdManager *)manager didReceiveAdConfiguration: (LoopMeAdConfiguration *)adConfiguration {
    if (!adConfiguration) {
        LoopMeLogDebug(@"Could not process ad: interstitial format expected.");
        [self failedLoadingAdWithError: [LoopMeError errorForStatusCode: LoopMeErrorCodeIncorrectFormat]];
        return;
    }
    self.adConfiguration = adConfiguration;
    self.adConfiguration.placement = @"banner";
    if (@available(iOS 14.5, *)) {
        self.skAdImpression = [[SKAdImpression alloc] init];
        // iOS 16.0 and later
        if (@available(iOS 16.0, *)) {
            self.skAdImpression = [[SKAdImpression alloc]
                                   initWithSourceAppStoreItemIdentifier: (NSNumber *)self.adConfiguration.skadSourceApp
                                   advertisedAppStoreItemIdentifier: (NSNumber *)self.adConfiguration.skadItunesitem
                                   adNetworkIdentifier: (NSString *)self.adConfiguration.skadNetwork
                                   adCampaignIdentifier: (NSNumber *)self.adConfiguration.skadCampaign
                                   adImpressionIdentifier: (NSString *)self.adConfiguration.skadNonce
                                   timestamp: (NSNumber *)self.adConfiguration.skadTimestamp
                                   signature: (NSString *)self.adConfiguration.skadSignature
                                   version: (NSString *)self.adConfiguration.skadVersion];
            // iOS 16.1 and later
            if (@available(iOS 16.1, *)) {
                if  (![self.adConfiguration.skadSourceidentifier isEqualToNumber: @(0)]) {
                    [self.skAdImpression setSourceIdentifier: self.adConfiguration.skadSourceidentifier];
                }
            }
        } else {
            // iOS versions earlier than 16.0
            self.skAdImpression.adNetworkIdentifier = self.adConfiguration.skadNetwork;
            self.skAdImpression.signature = self.adConfiguration.skadSignature;
            self.skAdImpression.version = self.adConfiguration.skadVersion;
            self.skAdImpression.timestamp = self.adConfiguration.skadTimestamp;
            self.skAdImpression.sourceAppStoreItemIdentifier = self.adConfiguration.skadItunesitem;
            if  (![self.adConfiguration.skadSourceidentifier isEqualToNumber:@(0)]) {
                self.skAdImpression.adCampaignIdentifier = self.adConfiguration.skadCampaign;
            }
            self.skAdImpression.advertisedAppStoreItemIdentifier = self.adConfiguration.skadItunesitem;
            self.skAdImpression.adImpressionIdentifier = self.adConfiguration.skadNonce;
        }
    }
    
    if ([LoopMeGlobalSettings sharedInstance].liveDebugEnabled ) {
        [LoopMeGlobalSettings sharedInstance].appKeyForLiveDebug = self.appKey;
    }
    
    if (adConfiguration.creativeType != LoopMeCreativeTypeVast) {
        [[LoopMeGlobalSettings sharedInstance].adIds setObject: adConfiguration.adIdsForMoat forKey: self.appKey];
        [self.adDisplayController setAdConfiguration: self.adConfiguration];
        [self.adDisplayController loadAdConfiguration];
    } else {
        [self.adDisplayControllerVPAID setAdConfiguration: self.adConfiguration];
    }
}

- (void)adManagerDidReceiveAd: (LoopMeAdManager *)manager {
    if (!self.adConfiguration) {
        [self failedLoadingAdWithError: [LoopMeVPAIDError errorForStatusCode: LoopMeVPAIDErrorCodeUndefined]];
        return;
    }
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeVast) {
        return;
    }
    [self.adDisplayControllerVPAID loadAdConfiguration];
}

- (void)adManager: (LoopMeAdManager *)manager didFailToLoadAdWithError: (NSError *)error {
    [self failedLoadingAdWithError: error];
}

- (void)adManagerDidExpireAd: (LoopMeAdManager *)manager {
    self.ready = NO;
    if ([self.delegate respondsToSelector: @selector(loopMeAdViewDidExpire:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate loopMeAdViewDidExpire: self];
        });
    }
}

#pragma mark - LoopMeMinimizedAdViewDelegate

- (void)minimizedAdViewShouldRemove: (LoopMeMinimizedAdView *)minimizedAdView {
    [self toOriginalSize];
    [self.minimizedView removeFromSuperview];
    self.minimizedView = nil;
    [self updateAdVisibilityInScrollView];
}

- (void)minimizedDidReceiveTap: (LoopMeMinimizedAdView *)minimizedAdView {
    [self.scrollView scrollRectToVisible: [self convertRect: self.bounds toView: self.scrollView] animated: YES];
}

#pragma mark - LoopMeMaximizedAdViewDelegate

- (void)setAdVisible:(BOOL)visible {
    if (!self.isReady) {
        return;
    }
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeVast) {
        self.adDisplayController.forceHidden = !visible;
        self.adDisplayController.visible = visible;
    } else {
        self.adDisplayControllerVPAID.visible = visible;
    }
    if (self.isMinimizedModeEnabled && self.scrollView) {
        if (!visible) {
            [self toOriginalSize];
        } else {
            [self updateAdVisibilityInScrollView];
        }
    }
}

- (void)maximizedAdViewDidPresent: (LoopMeMaximizedViewController *)maximizedViewController {
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeVast) {
        [self.adDisplayController layoutSubviews];
        [self setAdVisible: YES];
    } else {
        [self.adDisplayControllerVPAID layoutSubviews];
    }
}

- (void)maximizedViewControllerShouldRemove: (LoopMeMaximizedViewController *)maximizedViewController {
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeVast) {
        [self.adDisplayController moveView: NO];
    } else {
        [self.adDisplayControllerVPAID moveView: NO];
    }
}

- (void)maximizedControllerWillTransitionToSize: (CGSize)size {
    [self.adDisplayController resizeTo: size];
}

#pragma mark - LoopMeAdDisplayControllerNormalDelegate

- (UIView *)containerView {
    BOOL isMaximized = [self.maximizedController presentingViewController] != nil;
    if (self.isMinimized) {
        return self.minimizedView;
    }
    if (isMaximized) {
        return self.maximizedController.view;
    }
    return self;
}

- (UIViewController *)viewControllerForPresentation {
    return [self.maximizedController presentingViewController] ? self.maximizedController : self.delegate.viewControllerForPresentation;
}

- (void)adDisplayControllerDidFinishLoadingAd: (LoopMeAdDisplayControllerNormal *)adDisplayController {
    if (self.isReady) {
        return;
    }
    self.loading = NO;
    self.ready = YES;
    if (self.isNeedsToBeDisplayedWhenReady) {
        self.needsToBeDisplayedWhenReady = NO;
        [self displayAd];
    }
    [self invalidateTimer];
    if ([self.delegate respondsToSelector: @selector(loopMeAdViewDidLoadAd:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate loopMeAdViewDidLoadAd: self];
        });
    }
}

- (void)adDisplayController: (LoopMeAdDisplayControllerNormal *)adDisplayController didFailToLoadAdWithError: (NSError *)error {
    [self failedLoadingAdWithError: error];
}

- (void)adDisplayControllerDidReceiveTap: (LoopMeAdDisplayControllerNormal *)adDisplayController {
    if ([self isMaximizedControllerIsPresented] && self.adConfiguration.creativeType != LoopMeCreativeTypeMraid) {
        [self removeMaximizedView];
    }
    if ([self.delegate respondsToSelector: @selector(loopMeAdViewDidReceiveTap:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate loopMeAdViewDidReceiveTap: self];
        });
    }
}

- (void)adDisplayControllerWillLeaveApplication: (LoopMeAdDisplayControllerNormal *)adDisplayController {
    if ([self.delegate respondsToSelector: @selector(loopMeAdViewWillLeaveApplication:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate loopMeAdViewWillLeaveApplication: self];
        });
    }
}

- (void)adDisplayControllerVideoDidReachEnd: (LoopMeAdDisplayControllerNormal *)adDisplayController {
    [self performSelector: @selector(removeMinimizedView) withObject: nil afterDelay: 1.0];
    if ([self.maximizedController isBeingPresented]) {
        [self performSelector: @selector(removeMaximizedView) withObject: nil afterDelay: 1.0];
    }
    if ([self.delegate respondsToSelector: @selector(loopMeAdViewVideoDidReachEnd:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate loopMeAdViewVideoDidReachEnd: self];
        });
    }
}

- (void)adDisplayControllerDidDismissModal: (LoopMeAdDisplayControllerNormal *)adDisplayController {
    self.visibilityUpdated = NO;
    [self updateVisibility];
}

- (void)adDisplayControllerShouldCloseAd: (LoopMeAdDisplayControllerNormal *)adDisplayController {
    if (self.adConfiguration.creativeType == LoopMeCreativeTypeMraid && [self.maximizedController presentingViewController]) {
        [self removeMaximizedView];
        return;
    }
    if ([self.delegate respondsToSelector: @selector(loopMeAdViewWillDisappear:)]) {
        [self.delegate loopMeAdViewWillDisappear: self];
    }
    [self removeFromSuperview];
}

- (void)adDisplayControllerWillExpandAd: (LoopMeAdDisplayControllerNormal *)adDisplayController {
    [self expand];
}

- (void)adDisplayControllerWillCollapse: (LoopMeAdDisplayControllerNormal *)adDisplayController {
    [self removeMaximizedView];
}

- (void)adDisplayControllerAllowOrientationChange: (BOOL)allowOrientationChange orientation: (NSInteger)orientation {
    [self.maximizedController setAllowOrientationChange: allowOrientationChange];
    [self.maximizedController setOrientation: orientation];
    [self.maximizedController forceChangeOrientation];
}

- (void)adDisplayController: (LoopMeAdDisplayController *)adDisplayController willResizeAd: (CGSize)size {
    float x = self.frame.origin.x;
    float y = self.frame.origin.y;
    CGRect newFrame = CGRectMake(x, y, size.width, size.height);
    
    if (self.translatesAutoresizingMaskIntoConstraints) {
        self.frame = newFrame;
        return;
    }
    if (self.expandedWidth.isActive && self.expandedHeight.isActive) {
        self.expandedHeight.active = NO;
        self.expandedWidth.active = NO;
    } else {
        self.expandedHeight = [self.heightAnchor constraintEqualToConstant: size.height];
        self.expandedHeight.active = YES;
        self.expandedWidth = [self.widthAnchor constraintEqualToConstant: size.width];
        self.expandedWidth.active = YES;
    }
}


@end
