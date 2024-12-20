//
//  LoopMeInterstitial.m
//  LoopMeSDK
//
//  Created by Dmitriy Lihachov on 6/21/12.
//  Copyright (c) 2012 LoopMe. All rights reserved.
//

#import <LoopMeUnitedSDK/LoopMeUnitedSDK-Swift.h>
#import "LoopMeDefinitions.h"
#import "LoopMeInterstitialGeneral.h"
#import "LoopMeAdManager.h"
#import "LoopMeTargeting.h"
#import "LoopMeAdDisplayControllerNormal.h"
#import "LoopMeVPAIDAdDisplayController.h"
#import "LoopMeInterstitialViewController.h"
#import "LoopMeVPAIDError.h"
#import "LoopMeError.h"
#import "LoopMeLogging.h"
#import "LoopMeGlobalSettings.h"
#import "LoopMeErrorEventSender.h"
#import <StoreKit/StoreKit.h>


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
@property (nonatomic, strong) SKAdImpression *skAdImpression;
@property (nonatomic, assign) CGSize screenSize;
@property (nonatomic) BOOL isSkadnAvailable;


@end
// TODO: This class takes to much responsibility - refactor
@implementation LoopMeInterstitialGeneral

#pragma mark - Life Cycle

- (void)dealloc {
    if ([NSThread isMainThread]) {
        [self dismissAdInterstitialViewController];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self dismissAdInterstitialViewController];
        });
    }
}

- (instancetype)initWithAppKey: (NSString *)appKey
                      delegate: (id<LoopMeInterstitialGeneralDelegate>)delegate
                    isRewarded: (BOOL)isRewarded {
    return [self initWithAppKey: appKey preferredAdTypes: LoopMeAdTypeAll delegate: delegate isRewarded: isRewarded];
}

- (instancetype)initWithAppKey: (NSString *)appKey
              preferredAdTypes: (LoopMeAdType)adTypes
                      delegate: (id<LoopMeInterstitialGeneralDelegate>)delegate
                    isRewarded: (BOOL)isRewarded {
    if (self = [super init]) {
        _appKey = [appKey copy];
        _delegate = delegate;
        _adManager = [[LoopMeAdManager alloc] initWithDelegate:self];
        _preferredAdTypes = adTypes;
        // TODO: ???
        isRewarded = isRewarded;
        self.adDisplayController = [[LoopMeAdDisplayControllerNormal alloc] initWithDelegate:self];
        self.adDisplayController.isInterstitial = YES;
        
        self.adDisplayControllerVPAID = [[LoopMeVPAIDAdDisplayController alloc] initWithDelegate:self];
        self.adDisplayControllerVPAID.isInterstitial = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self->_adInterstitialViewController = [[LoopMeInterstitialViewController alloc] initWithNibName:nil bundle:nil];
            self->_adInterstitialViewController.modalPresentationStyle = UIModalPresentationFullScreen;
            self->_adInterstitialViewController.delegate = self;
        });
        LoopMeLogInfo(@"Interstitial is initialized with appKey %@", appKey);
    }
    return self;
}

#pragma mark - Class Methods

+ (LoopMeInterstitialGeneral *)interstitialWithAppKey: (NSString *)appKey
                                     preferredAdTypes: (LoopMeAdType)adTypes
                                             delegate: (id<LoopMeInterstitialGeneralDelegate>)delegate
                                           isRewarded: (BOOL)isRewarded {
    return [[LoopMeInterstitialGeneral alloc] initWithAppKey: appKey
                                            preferredAdTypes: adTypes
                                                    delegate: delegate
                                                  isRewarded: isRewarded];
}

#pragma mark - Private

- (void)unRegisterObserver {
    [[NSNotificationCenter defaultCenter] removeObserver: self name: UIApplicationWillResignActiveNotification object: nil];
    [[NSNotificationCenter defaultCenter] removeObserver: self name: UIApplicationDidBecomeActiveNotification object: nil];
}

- (void)registerObserver {
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(willResignActive:)
                                                 name: UIApplicationWillResignActiveNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(didBecomeActive:)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
}

- (void)dismissAdInterstitialViewController {
    if (self.adInterstitialViewController.presentingViewController) {
         [self.adInterstitialViewController.presentingViewController dismissViewControllerAnimated: NO completion: nil];
    }
    
     [_adManager invalidateTimers];
     [_adDisplayController stopHandlingRequests];
     [_adDisplayControllerVPAID stopHandlingRequests];
    
     _adDisplayController.delegate = nil;
     _adDisplayControllerVPAID.delegate = nil;
     _adManager = nil;
     _adDisplayController = nil;
     _adDisplayControllerVPAID = nil;
     _adInterstitialViewController = nil;
     [self invalidateTimer];
     [self unRegisterObserver];
}

- (void)willResignActive: (NSNotification *)n {
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeVast) {
        self.adDisplayController.visible = NO;
    } else {
        self.adDisplayControllerVPAID.visible = NO;
    }
}

- (void)didBecomeActive: (NSNotification *)n {
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeVast) {
        self.adDisplayController.visible = YES;
    } else {
        self.adDisplayControllerVPAID.visible = YES;
    }
}

- (void)failedLoadingAdWithError: (NSError *)error {
    self.loading = NO;
    self.ready = NO;
    if (self.adConfiguration.creativeType == LoopMeCreativeTypeVast) {
        [self.adDisplayControllerVPAID.vastEventTracker trackErrorCode: error.code];
    }
    
    [self invalidateTimer];
    if ([self.delegate respondsToSelector: @selector(loopMeInterstitial:didFailToLoadAdWithError:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate loopMeInterstitial: self didFailToLoadAdWithError: error];
        });
    }
}

- (void)startAd {
    [self.adDisplayControllerVPAID startAd];
}
#pragma mark - Public Mehtods

- (void)setServerBaseURL: (NSURL *)URL {
    self.adManager.testServerBaseURL = URL;
}

- (void)loadAd {
    [self loadAdWithTargeting: nil];
}

- (void)invalidateTimer {
    [self.timeoutTimer invalidate];
    self.timeoutTimer = nil;
}

- (void)timeOut: (NSTimer *)timer {
    if (self.timeoutTimer != timer) {
        return ;
    }
    NSMutableDictionary *infoDictionary = [self.adConfiguration toDictionary];
    [infoDictionary setObject:@"LoopMeInterstitialGeneral" forKey: kErrorInfoClass];
    [infoDictionary setObject:self.adConfiguration.creativeType == LoopMeCreativeTypeVast ? @"VAST" : @"NOT_VAST" forKey:kErrorInfoCreativeType];

    
    [LoopMeErrorEventSender sendError: LoopMeEventErrorTypeServer
                         errorMessage: @"Time out"
                                 info: infoDictionary];
    
    //-------NORMAL----
    [self.adDisplayController stopHandlingRequests];
    [self failedLoadingAdWithError: [LoopMeError errorForStatusCode: LoopMeErrorCodeHTMLRequestTimeOut]];
    
    //------VPAID-------
    [self.adDisplayControllerVPAID stopHandlingRequests];
    [self failedLoadingAdWithError: [LoopMeVPAIDError errorForStatusCode: LoopMeVPAIDErrorCodeUndefined]];
}

- (void)runTimeoutTimer {
    if (self.timeoutTimer) {
        [self invalidateTimer];
    }
    self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval: kLoopMeRequestTimeout
                                                         target: self
                                                       selector: @selector(timeOut:)
                                                       userInfo: nil
                                                        repeats: NO];
}

- (void)loadURL: (NSURL *)url {
    [self registerObserver];
    self.loading = YES;
    self.ready = NO;
    [self runTimeoutTimer];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.adManager loadURL: url];
    });
}

- (void)loadAdWithTargeting: (LoopMeTargeting *)targeting {
    [self loadAdWithTargeting: targeting integrationType: @"normal" isRewarded: self.isRewarded];
}

- (void)loadAdWithTargeting: (LoopMeTargeting *)targeting
            integrationType: (NSString *)integrationType
                 isRewarded: (BOOL)isRewarded {
    // self.adManager can be in loading state also
    // TODO: rethink this logic - we need to have only one source of truth
    if (self.isLoading || self.adManager.isLoading) {
        LoopMeLogInfo(@"Wait for previous loading ad process finish");
        return;
    }
    if (self.isReady) {
        LoopMeLogInfo(@"Ad already loaded and ready to be displayed");
        return;
    }
    self.screenSize = [self getSize];
    [self registerObserver];
    self.loading = YES;
    self.ready = NO;
    [self runTimeoutTimer];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.adManager loadAdWithAppKey: self.appKey
                               targeting: targeting
                         integrationType: integrationType
                              adSpotSize: self.screenSize
                                  adSpot: self
                        preferredAdTypes: self.preferredAdTypes
                              isRewarded: isRewarded];
    });
}

- (CGSize)getSize {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    NSString *orientation = screenSize.width < screenSize.height ? @"Portrait" : @"Landscape";
    NSString *deviceType = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"iPad" : @"iPhone";
    return [@{
        @"iPhone": @{
            @"Portrait": [NSValue valueWithCGSize: CGSizeMake(320, 480)],
            @"Landscape": [NSValue valueWithCGSize: CGSizeMake(480, 320)]
        },
        @"iPad": @{
            @"Portrait": [NSValue valueWithCGSize: CGSizeMake(768, 1024)],
            @"Landscape": [NSValue valueWithCGSize: CGSizeMake(1024, 768)]
        }
    }[deviceType][orientation] CGSizeValue];
}

- (void)showFromViewController: (UIViewController *)viewController animated: (BOOL)animated {
    self.isSkadnAvailable = !(self.adConfiguration.skadSourceidentifier == nil || [self.adConfiguration.skadSourceidentifier isEqualToNumber:@(0)]);
    if (self.isSkadnAvailable) {
        [self setupSKAdImpression];
    }
     
    NSMutableDictionary *infoDictionary = [self.adConfiguration toDictionary];
    [infoDictionary setObject:@"LoopMeInterstitialGeneral" forKey:kErrorInfoClass];
    
    if (!self.isReady) {
        LoopMeLogInfo(@"Ad isn't ready to be displayed");
        [LoopMeErrorEventSender sendError:LoopMeEventErrorTypeCustom
                            errorMessage:@"Ad isn't ready to be displayed"
                                    info:infoDictionary];
        return;
    }
    
    if (self.adInterstitialViewController.presentingViewController) {
        LoopMeLogInfo(@"Ad has already displayed");
        [LoopMeErrorEventSender sendError:LoopMeEventErrorTypeCustom
                            errorMessage:@"Ad has already displayed"
                                    info:infoDictionary];
        return;
    }
    
    LoopMeLogDebug(@"Interstitial ad will appear");
    if ([self.delegate respondsToSelector:@selector(loopMeInterstitialWillAppear:)]) {
        [self.delegate loopMeInterstitialWillAppear:self];
    }
    
    [self.adManager invalidateTimers];
    [self.adInterstitialViewController setOrientation:self.adConfiguration.adOrientation];
    [self.adInterstitialViewController setAllowOrientationChange:self.adConfiguration.allowOrientationChange];
    
    [self displayAd];
    
    [viewController presentViewController:self.adInterstitialViewController animated:animated completion:^{
        [self handleAdAppearance];
    }];
}

- (void)setupSKAdImpression {
    if (@available(iOS 16.0, *)) {
        self.skAdImpression = [[SKAdImpression alloc] initWithSourceAppStoreItemIdentifier:(NSNumber *)self.adConfiguration.skadSourceApp
                            advertisedAppStoreItemIdentifier:(NSNumber *)self.adConfiguration.skadItunesitem
                            adNetworkIdentifier:(NSString *)self.adConfiguration.skadNetwork
                            adCampaignIdentifier:(NSNumber *)self.adConfiguration.skadCampaign
                            adImpressionIdentifier:(NSString *)self.adConfiguration.skadNonce
                            timestamp:(NSNumber *)self.adConfiguration.skadTimestamp
                            signature:(NSString *)self.adConfiguration.skadSignature
                            version:(NSString *)self.adConfiguration.skadVersion];
        
        if (@available(iOS 16.1, *)) {
                [self.skAdImpression setSourceIdentifier:self.adConfiguration.skadSourceidentifier];
        }
    } else {
        if (@available(iOS 14.5, *)) {
            self.skAdImpression = [[SKAdImpression alloc] init];
            self.skAdImpression.adNetworkIdentifier = self.adConfiguration.skadNetwork;
            self.skAdImpression.signature = self.adConfiguration.skadSignature;
            self.skAdImpression.version = self.adConfiguration.skadVersion;
            self.skAdImpression.timestamp = self.adConfiguration.skadTimestamp;
            self.skAdImpression.sourceAppStoreItemIdentifier = self.adConfiguration.skadItunesitem;
            
            self.skAdImpression.adCampaignIdentifier = self.adConfiguration.skadCampaign;
            
            self.skAdImpression.advertisedAppStoreItemIdentifier = self.adConfiguration.skadItunesitem;
            self.skAdImpression.adImpressionIdentifier = self.adConfiguration.skadNonce;
        }
    }
}

- (void)displayAd {
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeVast) {
        [self.adDisplayController displayAd];
        self.adDisplayController.visible = YES;
    } else {
        [self.adDisplayControllerVPAID displayAd];
        self.adDisplayControllerVPAID.visible = YES;
    }
    if (self.isSkadnAvailable) {
        [self startSKAdImpression];
    }
}

- (void)handleAdAppearance {
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeVast) {
        [self.adDisplayController layoutSubviews];
        [[LoopMeLifecycleManager shared] updateSessionDepthForKey:self.appKey];
    } else {
        [self startAd];
    }
    
    LoopMeLogDebug(@"Interstitial ad did appear");
    if ([self.delegate respondsToSelector:@selector(loopMeInterstitialDidAppear:)]) {
        [self.delegate loopMeInterstitialDidAppear:self];
    }
}

- (void)dismissAnimated: (BOOL)animated {
    if (!self.adInterstitialViewController.presentingViewController) {
        return;
    }
    self.ready = NO;
    LoopMeLogDebug(@"Interstitial ad will disappear");
    if ([self.delegate respondsToSelector: @selector(loopMeInterstitialWillDisappear:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate loopMeInterstitialWillDisappear: self];
        });
    }
    
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeVast) {
        [self.adDisplayController closeAd];
    } else {
        [self.adDisplayControllerVPAID closeAd];
    }
    [self unRegisterObserver];
    if (self.isSkadnAvailable) {
        [self endSKAdImpression];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.adInterstitialViewController.presentingViewController dismissViewControllerAnimated: animated completion: ^{
            LoopMeLogDebug(@"Interstitial ad did disappear");
            if ([self.delegate respondsToSelector: @selector(loopMeInterstitialDidDisappear:)]) {
                [self.delegate loopMeInterstitialDidDisappear: self];
            }
        }];
    });
}

#pragma  mark - SkadNetwork func

- (void)startSKAdImpression {
    // Create an SKAdImpression instance
    if (@available(iOS 14.5, *)) {
        [SKAdNetwork startImpression: self.skAdImpression completionHandler: ^(NSError * _Nullable error) {
            if (error) {
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
                NSLog(@"Error ending SKAdImpression: %@", error.localizedDescription);
            } else {
                NSLog(@"SKAdImpression started successfully");
            }
        }];
    }
}

#pragma mark - LoopMeAdManagerDelegate

- (void)adManager: (LoopMeAdManager *)manager didReceiveAdConfiguration: (LoopMeAdConfiguration *)adConfiguration {
    self.adConfiguration = adConfiguration;
    if ([LoopMeGlobalSettings sharedInstance].liveDebugEnabled ) {
        [LoopMeGlobalSettings sharedInstance].appKeyForLiveDebug = self.appKey;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (adConfiguration.creativeType == LoopMeCreativeTypeVast) {
            return [self.adDisplayControllerVPAID setAdConfiguration: self.adConfiguration];
        }
        [self.adDisplayController setAdConfiguration: self.adConfiguration];
        [self.adDisplayController loadAdConfiguration];
    });
}

- (void)adManagerDidReceiveAd: (LoopMeAdManager *)manager {
    if (!self.adConfiguration) return;
    if (self.adConfiguration.creativeType == LoopMeCreativeTypeVast) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.adDisplayControllerVPAID loadAdConfiguration];
            [self adDisplayControllerDidFinishLoadingAd:self.adDisplayControllerVPAID];
        });
    } else {
        [self adDisplayControllerDidFinishLoadingAd: self.adDisplayController];
    }
}

- (void)adManager: (LoopMeAdManager *)manager didFailToLoadAdWithError: (NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self failedLoadingAdWithError: error];
    });
}

- (void)adManagerDidExpireAd: (LoopMeAdManager *)manager {
    self.ready = NO;
    if ([self.delegate respondsToSelector: @selector(loopMeInterstitialDidExpire:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate loopMeInterstitialDidExpire: self];
        });
    }
}

#pragma mark - LoopMeInterstitialViewControllerDelegate

- (void)viewWillTransitionToSize: (CGSize)size {
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeVast) {
        [self.adDisplayController layoutSubviewsToFrame: CGRectMake(0, 0, size.width, size.height)];
        [self.adDisplayController resizeTo: size];
    } else {
        [self.adDisplayControllerVPAID layoutSubviewsToFrame: CGRectMake(0, 0, size.width, size.height)];
    }
}

#pragma mark - LoopMeAdDisplayControllerDelegate

- (UIViewController *)viewControllerForPresentation {
    return self.adInterstitialViewController;
}

- (UIView *)containerView {
    return self.adInterstitialViewController.view;
}

- (void)adDisplayControllerDidFinishLoadingAd: (LoopMeAdDisplayControllerNormal *)adDisplayController {
    if (self.isReady) {
        return;
    }
    self.loading = NO;
    self.ready = YES;
    [self invalidateTimer];
    if ([self.delegate respondsToSelector: @selector(loopMeInterstitialDidLoadAd:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate loopMeInterstitialDidLoadAd: self];
        });
    }
}

- (void)adDisplayController: (LoopMeAdDisplayControllerNormal *)adDisplayController didFailToLoadAdWithError: (NSError *)error {
    [self failedLoadingAdWithError: error];
}

- (void)adDisplayControllerDidReceiveTap: (LoopMeAdDisplayControllerNormal *)adDisplayController {
    if ([self.delegate respondsToSelector: @selector(loopMeInterstitialDidReceiveTap:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate loopMeInterstitialDidReceiveTap: self];
        });
    }
}

- (void)adDisplayControllerWillLeaveApplication: (LoopMeAdDisplayControllerNormal *)adDisplayController {
    if ([self.delegate respondsToSelector: @selector(loopMeInterstitialWillLeaveApplication:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate loopMeInterstitialWillLeaveApplication: self];
        });
    }
}

- (void)adDisplayControllerVideoDidReachEnd: (LoopMeAdDisplayControllerNormal *)adDisplayController {
    if ([self.delegate respondsToSelector: @selector(loopMeInterstitialVideoDidReachEnd:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate loopMeInterstitialVideoDidReachEnd: self];
        });
    }
}

- (void)adDisplayControllerWillExpandAd: (LoopMeAdDisplayControllerNormal *)adDisplayController { }

- (void)adDisplayControllerShouldCloseAd: (LoopMeAdDisplayControllerNormal *)adDisplayController {
    [self dismissAnimated: NO];
}

- (void)adDisplayControllerDidDismissModal: (LoopMeAdDisplayControllerNormal *)adDisplayController {
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeVast) {
        self.adDisplayController.visible = YES;
    } else {
        self.adDisplayControllerVPAID.visible = YES;
    }
}

- (void)adDisplayControllerWillCollapse: (LoopMeAdDisplayControllerNormal *)adDisplayController { }

@end
