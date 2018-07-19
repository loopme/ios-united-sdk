//
//  LoopMeVPAIDAdDisplayController.m
//  LoopMeSDK
//
//  Copyright (c) 2016 LoopMe. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <LOOMoatMobileAppKit/LOOMoatAnalytics.h>
#import <LOOMoatMobileAppKit/LOOMoatWebTracker.h>

#import "LoopMeIASWrapper.h"
#import "LoopMeVPAIDClient.h"
#import "LoopMeVPAIDAdDisplayController.h"
#import "LoopMeAdConfiguration.h"
#import "LoopMeDestinationDisplayController.h"
#import "LoopMeVPAIDVideoClient.h"
#import "LoopMeVASTImageDownloader.h"
#import "LoopMeVPAIDError.h"
#import "LoopMeError.h"
#import "LoopMeLogging.h"
#import "LoopMeAdWebView.h"
#import "LoopMeErrorEventSender.h"
#import "LoopMeDefinitions.h"
#import "LoopMeCloseButton.h"
#import "LoopMeAdDisplayControllerNormal.h"
#import "LoopMeViewabilityProtocol.h"
#import "LoopMeViewabilityManager.h"

NSInteger const kLoopMeVPAIDImpressionTimeout = 2;

@interface LoopMeVPAIDAdDisplayController ()
<
    LoopMeVPAIDVideoClientDelegate,
    LoopMeVASTImageDownloaderDelegate,
    LoopMeVpaidProtocol,
    UIWebViewDelegate,
    LoopMeViewabilityProtocol
>

@property (nonatomic, strong) LoopMeCloseButton *closeButton;

@property (nonatomic, strong) LoopMeVPAIDClient *vpaidClient;
@property (nonatomic, strong) LoopMeVASTImageDownloader *imageDownloader;

@property (nonatomic, assign) NSInteger loadImageCounter;
@property (nonatomic, assign) NSInteger loadVideoCounter;

@property (nonatomic, strong) NSTimer *impressionTimeOutTimer;
@property (nonatomic, strong) NSTimer *showCloseButtonTimer;

@property (nonatomic, strong) LoopMeVASTEventTracker *vastEventTracker;

@property (nonatomic, strong) LOOMoatWebTracker *tracker;

@property (nonatomic, assign) BOOL needCloseCallback;
@property (nonatomic, assign) BOOL isNeedJSInject;
@property (nonatomic, assign) BOOL isNotPlay;
@property (nonatomic, assign) BOOL isVideoVPAID;
@property (nonatomic, assign) BOOL isDeferredAdStopped;
@property (nonatomic, assign) BOOL isTimerCloseButtonPaused;

@property (nonatomic, assign) double videoDuration;
@property (nonatomic, assign) double lastVolume;
@property (nonatomic, assign) double currentVolume;
@property (nonatomic, assign) int showCloseButtonTimerCounter;

@property (nonatomic, strong) LoopMeIASWrapper *iasWarpper;

- (void)handleVpaidStop;

@end

@implementation LoopMeVPAIDAdDisplayController

#pragma mark - Properties

- (LoopMeVASTImageDownloader *)imageDownloader {
    if (_imageDownloader == nil) {
        _imageDownloader = [[LoopMeVASTImageDownloader alloc] initWithDelegate:self];
    }
    return _imageDownloader;
}

- (LoopMeVASTEventTracker *)vastEventTracker {
    return _vastEventTracker;
}

- (void)setVisible:(BOOL)visible {
    if (self.isNotPlay) {
        return;
    }
    if (super.visible != visible) {
        super.visible = visible;
        if (visible) {
            [self.vpaidClient resumeAd];
        } else {
            [self.vpaidClient pauseAd];
        }
    }
}

- (double)videoDuration {
    if (_videoDuration <= 0) {
        _videoDuration = [self.adConfiguration duration].value;
    }
    return _videoDuration;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[LoopMeCloseButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        [_closeButton addTarget:self action:@selector(closeAdByButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (CGRect)frameForCloseButton:(CGRect)superviewFrame {
    return CGRectMake(superviewFrame.size.width - 50, 0, 50, 50);
}

#pragma mark - Life Cycle

- (void)dealloc {
    self.webView.delegate = nil;
    self.vastEventTracker = nil;
}

- (instancetype)initWithDelegate:(id<LoopMeAdDisplayControllerDelegate>)delegate {
    self = [super initWithDelegate:delegate];
    if (self) {

        self.webView.delegate = self;
        _iasWarpper = [[LoopMeIASWrapper alloc] init];
        
        if ([self.adConfiguration useTracking:LoopMeTrackerName.moat]) {
            LOOMoatOptions *options = [[LOOMoatOptions alloc] init];
            options.debugLoggingEnabled = true;
            [[LOOMoatAnalytics sharedInstance] startWithOptions:options];
            _tracker = [LOOMoatWebTracker trackerWithWebComponent:self.webView];
        }
    }
    return self;
}

#pragma mark - Public

- (void)startAd {
    [self.vpaidClient startAd];
    self.impressionTimeOutTimer = [NSTimer scheduledTimerWithTimeInterval:kLoopMeVPAIDImpressionTimeout target:self selector:@selector(vpaidAdImpression) userInfo:nil repeats:NO];
    
    [self.closeButton removeFromSuperview];
}

- (void)setAdConfiguration:(LoopMeAdConfiguration *)configuration {
    if (configuration) {
        super.adConfiguration = configuration;
        self.vastEventTracker = [[LoopMeVASTEventTracker alloc] initWithTrackingLinks:super.adConfiguration.trackingLinks];
        self.vastEventTracker.viwableManager = self;
        
        if (!configuration.assetLinks.vpaidURL) {
            self.videoClient = [[LoopMeVPAIDVideoClient alloc] initWithDelegate:self];
            ((LoopMeVPAIDVideoClient *)self.videoClient).configuration = configuration;
            ((LoopMeVPAIDVideoClient *)self.videoClient).eventSender = self.vastEventTracker;
        }
    }
}

- (void)loadAdConfiguration {
    self.loadImageCounter = 0;
    self.loadVideoCounter = 0;
    self.needCloseCallback = YES;
    self.isNotPlay = YES;
    
    if (self.adConfiguration.assetLinks.vpaidURL) {
        NSString *htmlString = [self stringFromFile:@"loopmead" withExtension:@"html"];
        
        if (htmlString) {
            htmlString = [self injectAdVerification:htmlString];
        } else {
            [self.delegate adDisplayController:self didFailToLoadAdWithError:[LoopMeError errorForStatusCode:LoopMeErrorCodeNoResourceBundle]];
            return;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *finalHTML = [NSString stringWithFormat:htmlString, self.adConfiguration.assetLinks.vpaidURL];
            [self.webView loadHTMLString:finalHTML baseURL:[NSURL URLWithString:kLoopMeBaseURL]];
        });
        
        self.webViewTimeOutTimer = [NSTimer scheduledTimerWithTimeInterval:kLoopMeWebViewLoadingTimeout target:self selector:@selector(cancelWebView) userInfo:nil repeats:NO];
    } else {
        if ([self.adConfiguration useTracking:LoopMeTrackerName.ias]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.iasWarpper initWithPartnerVersion:LOOPME_SDK_VERSION creativeType:self.adConfiguration.creativeType adConfiguration:self.adConfiguration];
                [self.iasWarpper registerAdView:self.delegate.containerView];
                [self.iasWarpper registerFriendlyObstruction:self.webView];
            });
        }
        
        self.isNeedJSInject = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.webView loadHTMLString:[self makeVastVerificationHTML] baseURL:[NSURL URLWithString:kLoopMeBaseURL]];
        });
        
        NSURL *imageURL;
        if (self.adConfiguration.assetLinks.endCard.count) {
            imageURL = [NSURL URLWithString:[self.adConfiguration.assetLinks.endCard objectAtIndex:self.loadImageCounter]];
        }
        [self.imageDownloader loadImageWithURL:imageURL];
    }
    
}

- (void)displayAd {
    if ([self.adConfiguration useTracking:LoopMeTrackerName.ias]) {
        [self.iasWarpper recordReadyEvent];
        [self.iasWarpper recordAdLoadedEvent];
    }
    self.isNotPlay = NO;
    self.isDeferredAdStopped = NO;
    
    ((LoopMeVPAIDVideoClient *)self.videoClient).viewController = [self.delegate viewControllerForPresentation];
    CGRect adjustedFrame = [self adjusFrame:self.delegate.containerView.bounds];
    [self.videoClient adjustViewToFrame:adjustedFrame];
    [self.delegate.containerView addSubview:self.webView];
    [self.delegate.containerView bringSubviewToFront:self.webView];
    
    NSArray *constraintsH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[webview]-0-|" options:0 metrics:nil views:@{@"webview" : self.webView}];
    NSArray *constraintsV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[webview]-0-|" options:0 metrics:nil views:@{@"webview" : self.webView}];
    [self.delegate.containerView addConstraints:constraintsH];
    [self.delegate.containerView addConstraints:constraintsV];
    
    [(LoopMeVPAIDVideoClient *)self.videoClient willAppear];
    
    //AVID
    [self.iasWarpper recordAdImpressionEvent];
}

- (void)closeAd {
    self.needCloseCallback = NO;
    [self.showCloseButtonTimer invalidate];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.webView loadHTMLString:@"about:blank" baseURL:nil];
        [self closeAdPrivate];
        [self.webView removeFromSuperview];
    });
}

- (void)closeAdPrivate {
    self.visible = NO;
    [self.videoClient cancel];
    self.videoClient = nil;
    if (!self.isNotPlay) {
        [self.videoClient pause];
        //TODO check on skip
        [self.vpaidClient stopAd];
    }
    
    if ([self.adConfiguration useTracking:LoopMeTrackerName.ias]) {
        [self.iasWarpper clean];
        [self.iasWarpper unregisterAdView:self.webView];
        [self.iasWarpper endSession];
    }
}

- (void)closeAdByButton {
    self.needCloseCallback = YES;
    [self closeAdPrivate];
}

- (void)layoutSubviews {
    CGRect adjustedFrame = [self adjusFrame:self.delegate.containerView.bounds];
    [self.videoClient adjustViewToFrame:adjustedFrame];
}

- (void)layoutSubviewsToFrame:(CGRect)frame {
    CGRect adjustedFrame = [self adjusFrame:frame];
    [self.videoClient adjustViewToFrame:adjustedFrame];
}

- (void)stopHandlingRequests {
    [super stopHandlingRequests];
}

- (void)moveView:(BOOL)hideWebView {
    [(LoopMeVPAIDVideoClient *)self.videoClient moveView];
    [self displayAd];
    self.webView.hidden = hideWebView;
    ((LoopMeVPAIDVideoClient *)self.videoClient).vastUIView.hidden = hideWebView;
}

- (void)expandReporting {
    [self.adConfiguration.eventTracker trackEvent:LoopMeVASTEventTypeLinearExpand];
}

- (void)collapseReporting {
    [self.adConfiguration.eventTracker trackEvent:LoopMeVASTEventTypeLinearCollapse];
}

- (void)handleVpaidStop {
    
    if (self.destinationIsPresented) {
        self.isDeferredAdStopped = YES;
        return;
    }
    
    if (!self.isNotPlay) {
        [self.vpaidClient stopActionTimeOutTimer];
        [self stopHandlingRequests];
        self.visible = NO;
        self.isNotPlay = YES;
        
        if (self.needCloseCallback && [self.delegate respondsToSelector:@selector(adDisplayControllerShouldCloseAd:)]) {
            [self.adConfiguration.eventTracker trackEvent:LoopMeVASTEventTypeLinearClose];
            [self.delegate adDisplayControllerShouldCloseAd:self];
        }
    }
}

#pragma mark - Private

- (NSString *)stringFromFile:(NSString *)filename withExtension:(NSString *)extension {
    NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"LoopMeResources" withExtension:@"bundle"];
    if (!bundleURL) {
        return nil;
    }
    NSBundle *resourcesBundle = [NSBundle bundleWithURL:bundleURL];
    NSString *htmlPath = [resourcesBundle pathForResource:filename ofType:extension];
    return [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:NULL];
}

- (NSString *)injectAdVerification:(NSString *)htmlString {
    if (self.adConfiguration.assetLinks.adVerification.count == 0) {
        return htmlString;
    }
    
    NSMutableString *copyHTMLstring = [htmlString mutableCopy];
    NSMutableString *pattern = [NSMutableString new];
    for (NSString *script in self.adConfiguration.assetLinks.adVerification) {
        [pattern appendString:[NSString stringWithFormat:@"\"%@\",", script]];
    }
    //remove last ','
    if (pattern.length) {
        pattern = [[pattern substringToIndex:[pattern length] - 1] mutableCopy];
    }
    
    [copyHTMLstring replaceOccurrencesOfString:@"[SCRIPTPLACE]" withString:pattern options:0 range:NSMakeRange(0, [htmlString length])];
    
    return copyHTMLstring;
}

- (NSString *)makeVastVerificationHTML {
    NSString *htmlString = [self stringFromFile:@"loopmevast4" withExtension:@"html"];
    htmlString = [self injectAdVerification:htmlString];
    return htmlString;
}

- (CGRect)adjusFrame:(CGRect)frame {
    CGRect result = frame;
    if (!self.adConfiguration.isVPAID && self.isInterstitial && [self adOrientationMatchContainer:frame]) {
        result = CGRectMake(frame.origin.x, frame.origin.y, frame.size.height, frame.size.width);
    }
    
    return result;
}

- (BOOL)isVertical:(CGRect)frame {
    return frame.size.width < frame.size.height;
}

- (BOOL)adOrientationMatchContainer:(CGRect)frame {
    return (!self.adConfiguration.isPortrait && [self isVertical:frame]) ||
     (self.adConfiguration.isPortrait && ![self isVertical:frame]);
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *URL = [request URL];
    if (self.adConfiguration.assetLinks.vpaidURL && [[URL absoluteString] isEqualToString:kLoopMeBaseURL]) {
        self.isNeedJSInject = YES;
    }
    if ([self shouldIntercept:URL navigationType:navigationType]) {
        [self.adConfiguration.eventTracker trackEvent:LoopMeVASTEventTypeLinearClickTracking];
        self.isTimerCloseButtonPaused = YES;
        [self.destinationDisplayClient displayDestinationWithURL:URL];
        return NO;
    }
    if ([URL.scheme isEqualToString:@"lmscript"]) {
        if ([URL.host isEqualToString:@"notloaded"]) {
            [self.vastEventTracker trackError:LoopMeVPAIDErrorCodeVerificationFail];
        }
    }
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    LoopMeLogDebug(@"WebView received an error %@", error);
    if (error.code == -1004) {
        if ([self.delegate respondsToSelector:@selector(adDisplayController:didFailToLoadAdWithError:)]) {
            [self.delegate adDisplayController:self didFailToLoadAdWithError:error];
        }
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    // UIWebView object has fully loaded.
    if (self.isNeedJSInject) {
        self.isNeedJSInject = NO;
        JSContext *jsContext = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
        JSValue *slot = [jsContext evaluateScript:@"document.getElementById('loopme-slot')"];
        JSValue *videoSlot = [jsContext evaluateScript:@"document.getElementById('loopme-videoslot')"];
        self.vpaidClient = [[LoopMeVPAIDClient alloc] initWithDelegate:self jsContext:jsContext];
        
        if ([self.vpaidClient handshakeVersion] > 0) {
            CGRect windowRect = [UIApplication sharedApplication].keyWindow.bounds;
            if ([self isVertical:windowRect]) {
               [self.vpaidClient initAdWithWidth:windowRect.size.height height:windowRect.size.width viewMode:LoopMeVPAIDViewMode.fullscreen desiredBitrate:720 creativeData:self.adConfiguration.assetLinks.adParameters environmentVars:@{@"slot": slot, @"videoSlot" : videoSlot, @"videoSlotCanAutoPlay" : @(YES)}];
            } else {
                [self.vpaidClient initAdWithWidth:windowRect.size.width height:windowRect.size.height viewMode:LoopMeVPAIDViewMode.fullscreen desiredBitrate:720 creativeData:self.adConfiguration.assetLinks.adParameters environmentVars:@{@"slot": slot, @"videoSlot" : videoSlot, @"videoSlotCanAutoPlay" : @(YES)}];
            }
        } else {
            [self.delegate adDisplayController:self didFailToLoadAdWithError:[LoopMeVPAIDError errorForStatusCode:LoopMeVPAIDErrorCodeMediaNotFound]];
        }
    }
}

- (void)showCloseButtonTimerTick {
    if (self.isTimerCloseButtonPaused) {
        return;
    }
    self.showCloseButtonTimerCounter += 1;
    CMTimeValue duration = [self.adConfiguration duration].value;
    if (self.showCloseButtonTimerCounter >= duration) {
        [self.showCloseButtonTimer invalidate];
        [self showCloseButton];
        return;
    }
}

- (void)showCloseButton {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.closeButton.frame = [self frameForCloseButton:self.webView.frame];
        [self.delegate.containerView addSubview:self.closeButton];
    });
}

#pragma mark - VpaidClientDelegate

- (void)vpaidJSError:(NSString *)message {
    if (self.isNotPlay) {
        [self stopHandlingRequests];
        NSError *error = [LoopMeVPAIDError errorForStatusCode:LoopMeVPAIDErrorCodeVPAIDError];
        [self.delegate adDisplayController:self didFailToLoadAdWithError:error];
    }
    
    [LoopMeErrorEventSender sendError:LoopMeEventErrorTypeJS errorMessage:message appkey:self.adConfiguration.appKey];
    [self.vastEventTracker trackError:LoopMeVPAIDErrorCodeVPAIDError];
}

- (void)vpaidAdLoaded {
    LoopMeLogDebug(@"VPAID ad loaded");
    [self.vpaidClient stopActionTimeOutTimer];
    [self.webViewTimeOutTimer invalidate];
    self.webViewTimeOutTimer = nil;
    self.currentVolume = [self.vpaidClient getAdVolume];
    self.lastVolume = self.currentVolume;
    
    if ([self.delegate respondsToSelector:@selector(adDisplayControllerDidFinishLoadingAd:)]) {
        [self.delegate adDisplayControllerDidFinishLoadingAd:self];
    }
}

- (void)vpaidAdSizeChange {
    LoopMeLogDebug(@"VPAID size change");
}

- (void)vpaidAdStarted {
    LoopMeLogDebug(@"VPAID ad started");
    [self.vpaidClient stopActionTimeOutTimer];
    [self.vastEventTracker trackEvent:LoopMeVASTEventTypeLinearCreativeView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.showCloseButtonTimerCounter = 0;
         self.showCloseButtonTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(showCloseButtonTimerTick) userInfo:nil repeats:YES];
    });
}

- (void)vpaidAdPaused {
    [self.vastEventTracker trackEvent:LoopMeVASTEventTypeLinearPause];
}

- (void)vpaidAdPlaying {
    [self.vastEventTracker trackEvent:LoopMeVASTEventTypeLinearResume];
}

- (void)vpaidAdExpandedChange {
    LoopMeLogDebug(@"VPAID Ad ExpandedChange");
}

- (void)vpaidAdSkipped {
    [self.vastEventTracker trackEvent:LoopMeVASTEventTypeLinearSkip];
    [self handleVpaidStop];
}

- (void)vpaidAdStopped {
    [self handleVpaidStop];
}

- (void)vpaidAdVolumeChanged {
    self.currentVolume = [self.vpaidClient getAdVolume];
    
    if (self.currentVolume == 0 && self.lastVolume > 0) {
        [self.vastEventTracker trackEvent:LoopMeVASTEventTypeLinearMute];
    }
    if (self.currentVolume > 0 && self.lastVolume == 0) {
        [self.vastEventTracker trackEvent:LoopMeVASTEventTypeLinearUnmute];
    }
    self.lastVolume = self.currentVolume;
}

- (void)vpaidAdSkippableStateChange {
    LoopMeLogDebug(@"VPAID Ad SkippableStateChange");
}

- (void)vpaidAdLinearChange {
    LoopMeLogDebug(@"VPAID Ad LinearChange");
}

- (void)vpaidAdDurationChange {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!self.isVisible) {
            return;
        }
        
        NSInteger adRemainingTime = self.vpaidClient.getAdRemainingTime;
        if (adRemainingTime < 0) {
            return;
        }
        double currentTime = self.videoDuration - self.vpaidClient.getAdRemainingTime;
        [self.vastEventTracker setCurrentTime:currentTime];
    });
}

- (void)vpaidAdRemainingTimeChange {
    double currentTime = self.videoDuration - self.vpaidClient.getAdRemainingTime;
    [self.vastEventTracker setCurrentTime:currentTime];
}

- (void)vpaidAdImpression {
    [self.impressionTimeOutTimer invalidate];
    [self.vastEventTracker trackEvent:LoopMeVASTEventTypeImpression];
}

- (void)vpaidAdVideoStart {
    [self.vastEventTracker trackEvent:LoopMeVASTEventTypeLinearStart];
}

- (void)vpaidAdVideoFirstQuartile {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.showCloseButtonTimer invalidate];
    });
    [self.vastEventTracker trackEvent:LoopMeVASTEventTypeLinearFirstQuartile];
}

- (void)vpaidAdVideoMidpoint {
    [self.vastEventTracker trackEvent:LoopMeVASTEventTypeLinearMidpoint];
}

- (void)vpaidAdVideoThirdQuartile {
    [self.vastEventTracker trackEvent:LoopMeVASTEventTypeLinearThirdQuartile];
}

- (void)vpaidAdVideoComplete {
    [self.vastEventTracker trackEvent:LoopMeVASTEventTypeLinearComplete];
}

- (void)vpaidAdClickThru:(NSString *)url id:(NSString *)Id playerHandles:(BOOL)playerHandles {
    [self.vastEventTracker trackEvent:LoopMeVASTEventTypeLinearClickTracking];
    NSString *clickURL = self.adConfiguration.trackingLinks.clickThroughVideo;
    self.isTimerCloseButtonPaused = YES;
    if (playerHandles) {
        if (!!url.length) {
            clickURL = url;
        }
        [self.destinationDisplayClient displayDestinationWithURL:[NSURL URLWithString:clickURL]];
    }
    if ([self.delegate respondsToSelector:@selector(adDisplayControllerDidReceiveTap:)]) {
        [self.delegate adDisplayControllerDidReceiveTap:self];
    }
}

- (void)vpaidAdInteraction:(NSString *)eventID {
    LoopMeLogDebug(@"VPAID Ad interaction: %@", eventID);
}

- (void)vpaidAdUserAcceptInvitation {
    LoopMeLogDebug(@"VPAID Ad UserAcceptInvitation");
}

- (void)vpaidAdUserMinimize {
    [self.vastEventTracker trackEvent:LoopMeVASTEventTypeLinearCollapse];
}

- (void)vpaidAdUserClose {
    [self.vastEventTracker trackEvent:LoopMeVASTEventTypeLinearClose];
}

- (void)vpaidAdError:(NSString *)error {
    LoopMeLogDebug(@"%@ Vpaid Ad error: ", error);
    [self.vastEventTracker trackError:LoopMeVPAIDErrorCodeVPAIDError];
    if ([self.delegate respondsToSelector:@selector(adDisplayControllerShouldCloseAd:)]) {
        [self.delegate adDisplayControllerShouldCloseAd:self];
    }
}

- (void)vpaidAdLog:(NSString *)message {
    LoopMeLogDebug(message);
}

- (void)vpaidAdVideoSource:(NSString *)videoSource {
    LoopMeLogDebug(videoSource);
    self.isVideoVPAID = YES;
}

- (NSString *)appKey {
    return self.adConfiguration.appKey;
}

#pragma mark - VideoClientDelegate

- (LoopMeSkipOffset)skipOffset {
    return self.adConfiguration.skipOffset;
}

- (void)videoClientDidLoadVideo:(LoopMeVPAIDVideoClient *)client {
    LoopMeLogInfo(@"Did load video ad");
    if ([self.delegate respondsToSelector:
         @selector(adDisplayControllerDidFinishLoadingAd:)]) {
        [self.delegate adDisplayControllerDidFinishLoadingAd:self];
    }
}

- (void)videoClient:(LoopMeVPAIDVideoClient *)client didFailToLoadVideoWithError:(NSError *)error {
    self.loadVideoCounter++;
    if (self.adConfiguration.assetLinks.videoURL.count > self.loadVideoCounter) {
        [self.vastEventTracker trackError:error.code];
        [self.videoClient loadWithURL:[NSURL URLWithString:self.adConfiguration.assetLinks.videoURL[self.loadVideoCounter]]];
        return;
    }
    LoopMeLogInfo(@"Did fail to load video ad");
    if ([self.delegate respondsToSelector:
         @selector(adDisplayController:didFailToLoadAdWithError:)]) {
        [self.delegate adDisplayController:self didFailToLoadAdWithError:error];
    }
}

- (void)videoClientDidReachEnd:(LoopMeVPAIDVideoClient *)client {
    LoopMeLogInfo(@"Video ad did reach end");
    if ([self.delegate respondsToSelector:
         @selector(adDisplayControllerVideoDidReachEnd:)]) {
        [self.delegate adDisplayControllerVideoDidReachEnd:self];
    }
}

- (void)videoClient:(LoopMeVPAIDVideoClient *)client setupView:(UIView *)view {
    dispatch_async(dispatch_get_main_queue(), ^{
        view.frame = [self adjusFrame:self.delegate.containerView.bounds];
        [self.iasWarpper registerFriendlyObstruction:view];
        [[self.delegate containerView] addSubview:view];
    });
}

- (void)videoClientShouldCloseAd:(LoopMeVPAIDVideoClient *)client {
    [self.vastEventTracker trackEvent:LoopMeVASTEventTypeLinearClose];
    if ([self.delegate respondsToSelector:@selector(adDisplayControllerShouldCloseAd:)]) {
        [self.delegate adDisplayControllerShouldCloseAd:self];
    }
}

- (void)videoClientDidVideoTap {
    self.isEndCardClicked = NO;
    self.isTimerCloseButtonPaused = YES;
    [self.videoClient pause];
    [self.adConfiguration.eventTracker trackEvent:LoopMeVASTEventTypeLinearClickTracking];
    if (self.adConfiguration.trackingLinks.clickThroughVideo) {
        [self.destinationDisplayClient displayDestinationWithURL:[NSURL URLWithString:self.adConfiguration.trackingLinks.clickThroughVideo]];
    }
    if ([self.delegate respondsToSelector:@selector(adDisplayControllerDidReceiveTap:)]) {
        [self.delegate adDisplayControllerDidReceiveTap:self];
    }
}

- (void)videoClientDidEndCardTap {
    self.isEndCardClicked = YES;
    self.isTimerCloseButtonPaused = YES;
    [self.adConfiguration.eventTracker trackEvent:LoopMeVASTEventTypeCompanionClickTracking];
    if (self.adConfiguration.trackingLinks.clickThroughCompanion) {
        [self.destinationDisplayClient displayDestinationWithURL:[NSURL URLWithString:self.adConfiguration.trackingLinks.clickThroughCompanion]];
    }
    if ([self.delegate respondsToSelector:@selector(adDisplayControllerDidReceiveTap:)]) {
        [self.delegate adDisplayControllerDidReceiveTap:self];
    }
}

- (void)videoClientDidExpandTap:(BOOL)expand {
    if (expand) {
        if ([self.delegate respondsToSelector:@selector(adDisplayControllerWillExpandAd:)]) {
            [self.delegate adDisplayControllerWillExpandAd:self];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(adDisplayControllerWillCollapse:)]) {
            [self.delegate adDisplayControllerWillCollapse:self];
        }
    }
    [self.videoClient setGravity:AVLayerVideoGravityResizeAspect];
}

- (void)videoClientDidBecomeActive:(LoopMeVPAIDVideoClient *)client {
    
    [self layoutSubviews];
    if (!self.destinationIsPresented && ![self.videoClient playerReachedEnd] && !self.isEndCardClicked && self.visible) {
        [self.videoClient play];
    }
}

#pragma mark - Destination Protocol

- (void)destinationDisplayControllerDidDismissModal:(LoopMeDestinationDisplayController *)destinationDisplayController {
    self.isTimerCloseButtonPaused = NO;
    [super destinationDisplayControllerDidDismissModal:destinationDisplayController];
    if (self.isDeferredAdStopped) {
        [self handleVpaidStop];
        [LoopMeErrorEventSender sendError:LoopMeEventErrorTypeCustom errorMessage:@"Deferred adStopped" appkey:self.appKey];
    }
}

#pragma mark - ImageDownloaderDelegate

- (void)imageDownloader:(LoopMeVASTImageDownloader *)downloader didLoadImage:(UIImage *)image withError:(NSError *)error {
    if (error) {
        [self.vastEventTracker trackError:error.code];
    }
    
    NSURL *videoURL;
    if (self.adConfiguration.assetLinks.videoURL.count) {
        videoURL = [NSURL URLWithString:self.adConfiguration.assetLinks.videoURL[self.loadVideoCounter]];
    }
    self.loadImageCounter++;
    if (image) {
        [((LoopMeVPAIDVideoClient *)self.videoClient).vastUIView setEndCardImage:image];
        [self.videoClient loadWithURL:videoURL];
    } else if (self.adConfiguration.assetLinks.endCard.count > self.loadImageCounter){
        [self.imageDownloader loadImageWithURL:[NSURL URLWithString:self.adConfiguration.assetLinks.endCard[self.loadImageCounter]]];
    } else {
        [self.videoClient loadWithURL:videoURL];
    }
}

#pragma mark LoopMeViewabilityProtocol

- (void)checkViwabilityCriteria {
    BOOL visible = [[LoopMeViewabilityManager sharedInstance] isViewable:self.delegate.containerView];
    if (visible) {
        [self.vastEventTracker trackEvent:LoopMeVASTEventTypeViewable];
    } else {
        [self.vastEventTracker trackEvent:LoopMeVASTEventTypeNotViewable];
    }
}

@end
