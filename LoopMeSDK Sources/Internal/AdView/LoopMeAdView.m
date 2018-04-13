//
//  Nativevideo.m
//  LoopMeSDK
//
//  Created by Kogda Bogdan on 2/13/15.
//  Copyright (c) 2012 LoopMe. All rights reserved.
//

#import "LoopMeAdView.h"
#import "LoopMeAdManager.h"
#import "LoopMeVPAIDAdDisplayController.h"
#import "LoopMeAdDisplayControllerNormal.h"
#import "LoopMeAdConfiguration.h"
#import "LoopMeDefinitions.h"
#import "LoopMeVPAIDError.h"
#import "LoopMeError.h"
#import "LoopMeLogging.h"
#import "LoopMeMinimizedAdView.h"
#import "LoopMeMaximizedViewController.h"
#import "LoopMeGlobalSettings.h"
#import "LoopMeErrorEventSender.h"
#import "LoopMeAnalyticsProvider.h"

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

/*
 * Update webView "visible" state is required on JS first time when ad appears on the screen,
 * further, we're ommiting sending "webView" states to JS but managing video ad. playback in-SDK
 */
@property (nonatomic, assign, getter = isVisibilityUpdated) BOOL visibilityUpdated;
@end

@implementation LoopMeAdView

#pragma mark - Initialization

- (void)dealloc {
    [self unRegisterObservers];
    [_minimizedView removeFromSuperview];
    [_maximizedController hide];
    //-------------NORMAL--------------
    [_adDisplayController stopHandlingRequests];
    //--------------VPAID----------
    [_adDisplayControllerVPAID stopHandlingRequests];
    //--------------------------
}

- (instancetype)initWithAppKey:(NSString *)appKey
                         frame:(CGRect)frame
                    scrollView:(UIScrollView *)scrollView
              preferredAdTypes:(LoopMeAdType)preferredAdTypes
                      delegate:(id<LoopMeAdViewDelegate>)delegate {
    self = [super init];
    if (self) {
        
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
        _adManager = [[LoopMeAdManager alloc] initWithDelegate:self];
        _adDisplayController = [[LoopMeAdDisplayControllerNormal alloc] initWithDelegate:self];
        _adDisplayControllerVPAID = [[LoopMeVPAIDAdDisplayController alloc] initWithDelegate:self];
        _maximizedController = [[LoopMeMaximizedViewController alloc] initWithDelegate:self];
        _scrollView = scrollView;
        self.frame = frame;
        self.backgroundColor = [UIColor clearColor];
        [self registerObservers];
        LoopMeLogInfo(@"Ad view initialized with appKey: %@", appKey);
        
        [LoopMeAnalyticsProvider sharedInstance];
    }
    return self;
}

- (void)setMinimizedModeEnabled:(BOOL)minimizedModeEnabled {
    if (_minimizedModeEnabled != minimizedModeEnabled) {
        _minimizedModeEnabled = minimizedModeEnabled;
        if (_minimizedModeEnabled) {
            _minimizedView = [[LoopMeMinimizedAdView alloc] initWithDelegate:self];
            _minimizedView.backgroundColor = [UIColor clearColor];
            _minimizedView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
            [[UIApplication sharedApplication].keyWindow addSubview:_minimizedView];
        } else {
            [self removeMinimizedView];
        }
    }
}

- (void)setDoNotLoadVideoWithoutWiFi:(BOOL)doNotLoadVideoWithoutWiFi {
    [LoopMeGlobalSettings sharedInstance].doNotLoadVideoWithoutWiFi = doNotLoadVideoWithoutWiFi;
}

- (void)expand {
    BOOL isMaximized = [self.maximizedController presentingViewController] != nil;
    if (!isMaximized) {
        if (self.adConfiguration.creativeType == LoopMeCreativeTypeMRAID) {
            [self.adDisplayController setExpandProperties:self.adConfiguration];
            [self.adDisplayController setOrientationProperties:nil];
        }
        [self.maximizedController show];
        
        if (self.adConfiguration.creativeType != LoopMeCreativeTypeVPAID) {
            [self.adDisplayController moveView:NO];
            [self.adDisplayController expandReporting];
        } else {
            [self.adDisplayControllerVPAID moveView:NO];
            [self.adDisplayControllerVPAID expandReporting];
        }
    }
}

#pragma mark - Class Methods

+ (LoopMeAdView *)adViewWithAppKey:(NSString *)appKey
                             frame:(CGRect)frame
                        scrollView:(UIScrollView *)scrollView
                          delegate:(id<LoopMeAdViewDelegate>)delegate {
    return [[self alloc] initWithAppKey:appKey frame:frame scrollView:scrollView preferredAdTypes:LoopMeAdTypeAll delegate:delegate];
}

+ (LoopMeAdView *)adViewWithAppKey:(NSString *)appKey
                             frame:(CGRect)frame
                          delegate:(id<LoopMeAdViewDelegate>)delegate {
    return [LoopMeAdView adViewWithAppKey:appKey frame:frame scrollView:nil preferredAdTypes:LoopMeAdTypeAll delegate:delegate];
}


+ (LoopMeAdView *)adViewWithAppKey:(NSString *)appKey
                             frame:(CGRect)frame
                        scrollView:(UIScrollView *)scrollView
                  preferredAdTypes:(LoopMeAdType)adTypes
                          delegate:(id<LoopMeAdViewDelegate>)delegate {
    
    return [[self alloc] initWithAppKey:appKey frame:frame scrollView:scrollView preferredAdTypes:adTypes delegate:delegate];
}

+ (LoopMeAdView *)adViewWithAppKey:(NSString *)appKey
                             frame:(CGRect)frame
                  preferredAdTypes:(LoopMeAdType)preferredAdTypes
                          delegate:(id<LoopMeAdViewDelegate>)delegate {
    
    return [LoopMeAdView adViewWithAppKey:appKey frame:frame scrollView:nil preferredAdTypes:preferredAdTypes delegate:delegate];
}

#pragma mark - LifeCycle

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (!newSuperview) {
        [self closeAd];
        if ([self.delegate respondsToSelector:@selector(loopMeAdViewWillDisappear:)]) {
            [self.delegate loopMeAdViewWillDisappear:self];
        }
    } else {
        if (!self.isReady) {
            [LoopMeErrorEventSender sendError:LoopMeEventErrorTypeCustom errorMessage:@"Banner added to view, but wasn't ready to be displayed" appkey:self.appKey];
            self.needsToBeDisplayedWhenReady = YES;
        }
        
        if ([self.delegate respondsToSelector:@selector(loopMeAdViewWillAppear:)]) {
            [self.delegate loopMeAdViewWillAppear:self];
        }
    }
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    if (self.superview && self.isReady)
        [self performSelector:@selector(displayAd) withObject:nil afterDelay:0.0];
}

#pragma mark - Observering

- (void)unRegisterObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)registerObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];

    
}

- (void)didBecomeActive:(NSNotification *)notification {
    if (self.superview) {
        self.visibilityUpdated = NO;
        [self updateVisibility];
    }
}

- (void)willResignActive:(NSNotification *)notification {
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeVPAID) {
        self.adDisplayController.visible = NO;
    } else {
        self.adDisplayControllerVPAID.visible = NO;
    }
    if ([self.maximizedController isBeingPresented]) {
        [self removeMaximizedView];
    }
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    [self.minimizedView rotateToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation animated:YES];
    [self.minimizedView adjustFrame];
}


#pragma mark - Public

- (void)setServerBaseURL:(NSURL *)URL {
    self.adManager.testServerBaseURL = URL;
}

- (void)loadAd {
    [self loadAdWithTargeting:nil integrationType:@"normal"];
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
    self.ready = NO;
    self.loading = YES;
    self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:180 target:self selector:@selector(timeOut) userInfo:nil repeats:NO];
    [self.adManager loadAdWithAppKey:self.appKey targeting:targeting integrationType:integrationType adSpotSize:self.containerView.bounds.size adSpot:self preferredAdTypes:self.preferredAdTypes];
}

- (void)setAdVisible:(BOOL)visible {
    if (self.isReady) {
        if (self.adConfiguration.creativeType != LoopMeCreativeTypeVPAID) {
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
}

- (void)updateAdVisibilityInScrollView {
    if (!self.superview) {
        return;
    }
    
    //-------------NORMAL----------------
    if ([self.maximizedController isBeingPresented]) {
        self.adDisplayController.visibleNoJS = YES;
        return;
    }
    
    if (self.adDisplayController.destinationIsPresented) {
        return;
    }
    //--------------------------

    CGRect relativeToScrollViewAdRect = [self convertRect:self.bounds toView:self.scrollView];
    CGRect visibleScrollViewRect = CGRectMake(self.scrollView.contentOffset.x, self.scrollView.contentOffset.y, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
    
    if (![self isRect:relativeToScrollViewAdRect outOfRect:visibleScrollViewRect]) {
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
    
    if ([self moreThenHalfOfRect:relativeToScrollViewAdRect visibleInRect:visibleScrollViewRect]) {
        [self updateAdVisibilityWhenScroll];
    //-----------NORMAL----------
    } else {
        self.adDisplayController.visibleNoJS = NO;
    }
    //------------------------------
}

#pragma mark - Private

- (void)minimize {
    if (!self.isMinimized && (self.adDisplayController.isVisible || self.adDisplayControllerVPAID.isVisible)) {
        self.minimized = YES;
        [self.minimizedView show];
        
        if (self.adConfiguration.creativeType != LoopMeCreativeTypeVPAID) {
            [self.adDisplayController moveView:YES];
        } else {
            [self.adDisplayControllerVPAID moveView:YES];
        }
    }
}

- (void)toOriginalSize {
    if (self.isMinimized) {
        self.minimized = NO;
        [self.minimizedView hide];
        
        if (self.adConfiguration.creativeType != LoopMeCreativeTypeVPAID) {
            [self.adDisplayController moveView:NO];
        } else {
            [self.adDisplayControllerVPAID moveView:NO];
        }
    }
}

- (void)removeMinimizedView {
    [self.minimizedView removeFromSuperview];
    self.minimizedView = nil;
}

- (void)removeMaximizedView {
    [self.maximizedController hide];
    
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeVPAID) {
        [self.adDisplayController moveView:NO];
        [self.adDisplayController collapseReporting];
    } else {
        [self.adDisplayControllerVPAID moveView:NO];
        [self.adDisplayControllerVPAID collapseReporting];
    }
}

- (BOOL)moreThenHalfOfRect:(CGRect)rect visibleInRect:(CGRect)visibleRect {
    return (CGRectContainsPoint(visibleRect, CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))));
}

- (BOOL)isRect:(CGRect)rect outOfRect:(CGRect)visibleRect {
    return CGRectIntersectsRect(rect, visibleRect);
}

- (void)failedLoadingAdWithError:(NSError *)error {
    self.loading = NO;
    self.ready = NO;
    
    if (self.adConfiguration.creativeType == LoopMeCreativeTypeVPAID) {
        [self.adDisplayControllerVPAID.vastEventTracker trackError:error.code];
    }
    
    [self invalidateTimer];
    if ([self.delegate respondsToSelector:@selector(loopMeAdView:didFailToLoadAdWithError:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate loopMeAdView:self didFailToLoadAdWithError:error];
        });
    }
}

- (void)updateVisibility {
    if (!self.scrollView) {
        if (self.adConfiguration.creativeType != LoopMeCreativeTypeVPAID) {
            self.adDisplayController.visible = YES;
        } else {
            self.adDisplayControllerVPAID.visible = YES;
            [self.adConfiguration.eventTracker trackEvent:LoopMeVASTEventTypeImpression];
            [self.adConfiguration.eventTracker trackEvent:LoopMeVASTEventTypeLinearCreativeView];
            [self.adDisplayControllerVPAID startAd];
        }
    } else {
        [self updateAdVisibilityInScrollView];
    }
}

- (void)updateAdVisibilityWhenScroll {
    if (!self.isVisibilityUpdated) {
        if (self.adConfiguration.creativeType != LoopMeCreativeTypeVPAID) {
            self.adDisplayController.visible = YES;
        } else {
            self.adDisplayControllerVPAID.visible = YES;
            [self.adConfiguration.eventTracker trackEvent:LoopMeVASTEventTypeImpression];
            [self.adConfiguration.eventTracker trackEvent:LoopMeVASTEventTypeLinearCreativeView];
            [self.adDisplayControllerVPAID startAd];
        }
    
        self.visibilityUpdated = YES;
    } else {
        self.adDisplayController.visibleNoJS = YES;
    }
}

- (void)closeAd {
    [self.minimizedView removeFromSuperview];
    [self.maximizedController hide];
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeVPAID) {
        [self.adDisplayController closeAd];
    } else {
        [self.adDisplayControllerVPAID closeAd];
    }
    self.ready = NO;
    self.loading = NO;
}

- (void)displayAd {
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeVPAID) {
        [self.adDisplayController displayAd];
    } else {
        [self.adDisplayControllerVPAID displayAd];
    }
    
    [self.adManager invalidateTimers];
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        return;
    }
    [self updateVisibility];
}

- (BOOL)isMaximizedControllerIsPresented {
    return self.maximizedController.isViewLoaded && self.maximizedController.view.window;
}

- (void)timeOut {
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeVPAID) {
        [self.adDisplayController stopHandlingRequests];
    } else {
        [self.adDisplayControllerVPAID stopHandlingRequests];
    }
   
    [LoopMeErrorEventSender sendError:LoopMeEventErrorTypeServer errorMessage:@"Time out" appkey:self.appKey];
    [self failedLoadingAdWithError:[LoopMeError errorForStatusCode:LoopMeErrorCodeHTMLRequestTimeOut]];
}

- (void)invalidateTimer {
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
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
    
    if (adConfiguration.creativeType != LoopMeCreativeTypeVPAID) {
        [[LoopMeGlobalSettings sharedInstance].adIds setObject:adConfiguration.adIdsForMOAT forKey:self.appKey];
        [self.adDisplayController setAdConfiguration:self.adConfiguration];
        [self.adDisplayController loadAdConfiguration];
    } else {
        [self.adDisplayControllerVPAID setAdConfiguration:self.adConfiguration];
    }    
}

- (void)adManagerDidReceiveAd:(LoopMeAdManager *)manager {
    if (self.adConfiguration.creativeType == LoopMeCreativeTypeVPAID) {
        if (!self.adConfiguration) {
            NSError *error = [LoopMeVPAIDError errorForStatusCode:LoopMeVPAIDErrorCodeUndefined];
            [self failedLoadingAdWithError:error];
            return;
        }
        [self.adDisplayControllerVPAID loadAdConfiguration];
    }}

- (void)adManager:(LoopMeAdManager *)manager didFailToLoadAdWithError:(NSError *)error {
    [self failedLoadingAdWithError:error];
}

- (void)adManagerDidExpireAd:(LoopMeAdManager *)manager {
    self.ready = NO;
    if ([self.delegate respondsToSelector:@selector(loopMeAdViewDidExpire:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate loopMeAdViewDidExpire:self];
        });
    }
}

#pragma mark - LoopMeMinimizedAdViewDelegate

- (void)minimizedAdViewShouldRemove:(LoopMeMinimizedAdView *)minimizedAdView {
    [self toOriginalSize];
    [self.minimizedView removeFromSuperview];
    self.minimizedView = nil;
    [self updateAdVisibilityInScrollView];
}

- (void)minimizedDidReceiveTap:(LoopMeMinimizedAdView *)minimizedAdView {
    CGRect relativeToScrollViewAdRect = [self convertRect:self.bounds toView:self.scrollView];
    [self.scrollView scrollRectToVisible:relativeToScrollViewAdRect animated:YES];
}

#pragma mark - LoopMeMaximizedAdViewDelegate

- (void)maximizedAdViewDidPresent:(LoopMeMaximizedViewController *)maximizedViewController {
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeVPAID) {
        [self.adDisplayController layoutSubviews];
        [self setAdVisible:YES];
    } else {
        [self.adDisplayControllerVPAID layoutSubviews];
    }
}

- (void)maximizedViewControllerShouldRemove:(LoopMeMaximizedViewController *)maximizedViewController {
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeVPAID) {
        [self.adDisplayController moveView:NO];
    } else {
        [self.adDisplayControllerVPAID moveView:NO];
    }
}

- (void)maximizedControllerWillTransitionToSize:(CGSize)size {
    [self.adDisplayController resizeTo:size];
}

#pragma mark - LoopMeAdDisplayControllerNormalDelegate

- (UIView *)containerView {
    BOOL isMaximized = [self.maximizedController presentingViewController] != nil;
    if (self.isMinimized) {
        return self.minimizedView;
    } else if (isMaximized) {
        return self.maximizedController.view;
    } else {
        return self;
    }
}

- (UIViewController *)viewControllerForPresentation {
    if ([self.maximizedController presentingViewController]) {
        return self.maximizedController;
    }

    return self.delegate.viewControllerForPresentation;
}

- (void)adDisplayControllerDidFinishLoadingAd:(LoopMeAdDisplayControllerNormal *)adDisplayController {
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
    if ([self.delegate respondsToSelector:@selector(loopMeAdViewDidLoadAd:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate loopMeAdViewDidLoadAd:self];
        });
    }
}

- (void)adDisplayController:(LoopMeAdDisplayControllerNormal *)adDisplayController didFailToLoadAdWithError:(NSError *)error {
    [self failedLoadingAdWithError:error];
}

- (void)adDisplayControllerDidReceiveTap:(LoopMeAdDisplayControllerNormal *)adDisplayController {
    if ([self isMaximizedControllerIsPresented] && self.adConfiguration.creativeType != LoopMeCreativeTypeMRAID) {
        [self removeMaximizedView];
    }
    if ([self.delegate respondsToSelector:@selector(loopMeAdViewDidReceiveTap:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate loopMeAdViewDidReceiveTap:self];
        });
    }
}

- (void)adDisplayControllerWillLeaveApplication:(LoopMeAdDisplayControllerNormal *)adDisplayController {
    if ([self.delegate respondsToSelector:@selector(loopMeAdViewWillLeaveApplication:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate loopMeAdViewWillLeaveApplication:self];
        });
    }
}

- (void)adDisplayControllerVideoDidReachEnd:(LoopMeAdDisplayControllerNormal *)adDisplayController {
    [self performSelector:@selector(removeMinimizedView) withObject:nil afterDelay:1.0];
    
    if ([self.maximizedController isBeingPresented]) {
        [self performSelector:@selector(removeMaximizedView) withObject:nil afterDelay:1.0];
    }
    
    if ([self.delegate respondsToSelector:@selector(loopMeAdViewVideoDidReachEnd:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate loopMeAdViewVideoDidReachEnd:self];
        });
    }
}

- (void)adDisplayControllerDidDismissModal:(LoopMeAdDisplayControllerNormal *)adDisplayController {
    self.visibilityUpdated = NO;
    [self updateVisibility];
}

- (void)adDisplayControllerShouldCloseAd:(LoopMeAdDisplayControllerNormal *)adDisplayController {
    if (self.adConfiguration.creativeType == LoopMeCreativeTypeMRAID && [self.maximizedController presentingViewController]) {
        [self removeMaximizedView];
        return;
    }
    if ([self.delegate respondsToSelector:@selector(loopMeAdViewWillDisappear:)]) {
        [self.delegate loopMeAdViewWillDisappear:self];
    }
    [self removeFromSuperview];
}

- (void)adDisplayControllerWillExpandAd:(LoopMeAdDisplayControllerNormal *)adDisplayController {
    [self expand];
}

- (void)adDisplayControllerWillCollapse:(LoopMeAdDisplayControllerNormal *)adDisplayController {
    [self removeMaximizedView];
}

- (void)adDisplayControllerAllowOrientationChange:(BOOL)allowOrientationChange orientation:(NSInteger)orientation {
    [self.maximizedController setAllowOrientationChange:allowOrientationChange];
    [self.maximizedController setOrientation:orientation];
    [self.maximizedController forceChangeOrientation];
}

- (void)adDisplayController:(LoopMeAdDisplayController *)adDisplayController willResizeAd:(CGSize)size {
    float x = self.frame.origin.x;
    float y = self.frame.origin.y;
    
    CGRect newFrame = CGRectMake(x, y, size.width, size.height);
    self.frame = newFrame;
}


@end
