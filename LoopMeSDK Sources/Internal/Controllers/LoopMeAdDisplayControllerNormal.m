//
//  LoopMeAdDisplayController.m
//  LoopMeSDK
//
//  Created by Dmitriy Lihachov on 8/21/12.
//  Copyright (c) 2013 LoopMe. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <LOOMoatMobileAppKit/LOOMoatAnalytics.h>
#import <LOOMoatMobileAppKit/LOOMoatWebTracker.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "LoopMeAdDisplayControllerNormal.h"
#import "LoopMeAdConfiguration.h"
#import "LoopMeAdWebView.h"
#import "LoopMeDefinitions.h"
#import "LoopMeDestinationDisplayController.h"
#import "LoopMeJSClient.h"
#import "LoopMeMRAIDClient.h"
#import "LoopMeVideoClientNormal.h"
#import "NSURL+LoopMeAdditions.h"
#import "LoopMeError.h"
#import "LoopMeLogging.h"
#import "LoopMe360ViewController.h"
#import "LoopMeInterstitialViewController.h"
#import "LoopMeCloseButton.h"
#import "LoopMeInterstitialGeneral.h"
#import "LoopMeErrorEventSender.h"
#import "LoopMeAdView.h"

NSString * const kLoopMeShakeNotificationName = @"DeviceShaken";

@interface LoopMeAdDisplayControllerNormal ()
<
    UIWebViewDelegate,
    LoopMeVideoClientDelegate,
    LoopMeJSClientDelegate,
    LoopMeMRAIDClientDelegate
>

@property (nonatomic, strong) LoopMeCloseButton *closeButton;
@property (nonatomic, strong) LoopMeJSClient *JSClient;
@property (nonatomic, strong) LoopMeMRAIDClient *mraidClient;
@property (nonatomic, strong) NSDictionary *orientationProperties;
@property (nonatomic, assign) CGSize originalSize;

@property (nonatomic, assign, getter=isFirstCallToExpand) BOOL firstCallToExpand;
@property (nonatomic, assign, getter=isUseCustomClose) BOOL useCustomClose;
@property (nonatomic, assign, getter=isExpanded) BOOL expanded;

@property (nonatomic, assign) CGPoint prevLoaction;
@property (nonatomic, strong) UIPanGestureRecognizer *panWebView;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchWebView;

@property (nonatomic, assign) BOOL adDisplayed;
@property (nonatomic, strong) LOOMoatWebTracker *moatTracker;

- (void)deviceShaken;
- (void)interceptURL:(NSURL *)URL;

@end

@implementation LoopMeAdDisplayControllerNormal

#pragma mark - Properties

- (id<LoopMeVideoCommunicatorProtocol>)videoClient {
    if (!super.videoClient) {
        super.videoClient = [[LoopMeVideoClientNormal alloc] initWithDelegate:self];
    }
    return super.videoClient;
}

- (void)setVisible:(BOOL)visible {
    if (self.adDisplayed && super.visible != visible) {
        
        if (_forceHidden) {
            super.visible = NO;
        } else {
            super.visible = visible;
        }
        
        if (self.adConfiguration.creativeType == LoopMeCreativeTypeMRAID) {
            NSString *stringBOOL = super.visible ? @"true" : @"false";
            [self.mraidClient executeEvent:LoopMeMRAIDFunctions.viewableChange params:@[stringBOOL]];
        }
        
        if (visible && !_forceHidden) {
            [self.JSClient executeEvent:LoopMeEvent.state forNamespace:kLoopMeNamespaceWebview param:LoopMeWebViewState.visible];
        } else {
            [self.JSClient executeEvent:LoopMeEvent.state forNamespace:kLoopMeNamespaceWebview param:LoopMeWebViewState.hidden];
        }
    }
}

- (void)setVisibleNoJS:(BOOL)visibleNoJS {
    if (_visibleNoJS != visibleNoJS) {
        _visibleNoJS = visibleNoJS;
        NSString *stringBOOL = visibleNoJS ? @"true" : @"false";
        if (self.adConfiguration.creativeType == LoopMeCreativeTypeMRAID) {
            [self.mraidClient executeEvent:LoopMeMRAIDFunctions.viewableChange params:@[stringBOOL]];
        }
        if (_visibleNoJS) {
            [self.videoClient play];
        } else {
            [self.videoClient pause];
        }
    }
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [[LoopMeCloseButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        _closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [_closeButton addTarget:self action:@selector(mraidClientDidReceiveCloseCommand:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (void)setUseCustomClose:(BOOL)useCustomClose {
    if (self.isExpanded) {
        return;
    }
    _useCustomClose = useCustomClose;
    self.closeButton.alpha = useCustomClose ? 0.011 : 1;
}

#pragma mark - Life Cycle

- (void)dealloc {
    self.webView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoopMeShakeNotificationName object:nil];
}

- (instancetype)initWithDelegate:(id<LoopMeAdDisplayControllerDelegate>)delegate {
    self = [super initWithDelegate:delegate];
    if (self) {
        
        self.delegate = delegate;
        _JSClient = [[LoopMeJSClient alloc] initWithDelegate:self];
        _mraidClient = [[LoopMeMRAIDClient alloc] initWithDelegate:self];
        
        if ([self.adConfiguration useTracking:LoopMeTrackerName.moat]) {
            //if frame is zero WebView display content incorrect
            LOOMoatOptions *options = [[LOOMoatOptions alloc] init];
            options.debugLoggingEnabled = true;
            [[LOOMoatAnalytics sharedInstance] startWithOptions:options];
            _moatTracker = [LOOMoatWebTracker trackerWithWebComponent:self.webView];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(deviceShaken) name:kLoopMeShakeNotificationName object:nil];
        self.webView.delegate = self;
        
        _firstCallToExpand = YES;
    }
    return self;
}

#pragma mark - Private

- (void)deviceShaken {
    [self.JSClient setShake];
}

- (void)interceptURL:(NSURL *)URL {
    [self.destinationDisplayClient displayDestinationWithURL:URL];
}

- (void)panWebView:(UIPanGestureRecognizer *)recognizer {
    CGPoint currentLocation = [recognizer locationInView:self.webView];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.prevLoaction = currentLocation;
    }
    
    LoopMe360ViewController *vc = [(LoopMeVideoClientNormal *)self.videoClient viewController360];
    [vc pan:currentLocation prevLocation:self.prevLoaction];
    self.prevLoaction = currentLocation;
}

- (void)pinchWebView:(UIPinchGestureRecognizer *)recognizer {
    LoopMe360ViewController *vc = [(LoopMeVideoClientNormal *)self.videoClient viewController360];
    [vc handlePinchGesture:recognizer];
}

- (void)setOrientation:(NSDictionary *)orientationProperties forConfiguration:(LoopMeAdConfiguration *)configuration {
    if (orientationProperties) {
        configuration.allowOrientationChange = [orientationProperties[@"allowOrientationChange"] boolValue];
        if ([orientationProperties[@"forceOrientation"] isEqualToString:@"portrait"]) {
            configuration.orientation = LoopMeAdOrientationPortrait;
        } else if ([orientationProperties[@"forceOrientation"] isEqualToString:@"landscape"]) {
            configuration.orientation = LoopMeAdOrientationLandscape;
        }
    }
}

- (void)setExpandProperties:(NSDictionary *)properties forConfiguration:(LoopMeAdConfiguration *)configuration {
    if (properties) {
        struct LoopMeMRAIDExpandProperties expandProperties;
        expandProperties.height = [properties[@"height"] intValue];
        expandProperties.width = [properties[@"width"] intValue];
        expandProperties.useCustomClose = [properties[@"useCustomClose"] boolValue];
        
        configuration.expandProperties = expandProperties;
    }
}

- (CGRect)frameForCloseButton:(CGRect)superviewFrame {
    return CGRectMake(superviewFrame.size.width - 50, 0, 50, 50);
}

- (UIInterfaceOrientation)calculatePreferredOrientstion:(BOOL)allowOrientationChange orientationProperties:(NSDictionary *)orientationProperties {
    
    UIInterfaceOrientation preferredOrientation;
    UIInterfaceOrientation currentInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (allowOrientationChange) {
        preferredOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    } else {
        if ([orientationProperties[@"forceOrientation"] isEqualToString:@"portrait"]) {
            if (UIInterfaceOrientationIsPortrait(currentInterfaceOrientation)) {
                // this will accomodate both portrait and portrait upside down
                preferredOrientation = currentInterfaceOrientation;
            } else {
                preferredOrientation = UIInterfaceOrientationPortrait;
            }
        } else if ([orientationProperties[@"forceOrientation"] isEqualToString:@"landscape"]) {
            if (UIInterfaceOrientationIsLandscape(currentInterfaceOrientation)) {
                // this will accomodate both landscape left and landscape right
                preferredOrientation = currentInterfaceOrientation;
            } else {
                preferredOrientation = UIInterfaceOrientationLandscapeLeft;
            }
        } else {
            preferredOrientation = currentInterfaceOrientation;
        }
    }
    return preferredOrientation;
}

#pragma mark - Public

- (void)setExpandProperties:(LoopMeAdConfiguration *)configuration {
    [self setExpandProperties:[self.mraidClient getExpandProperties] forConfiguration:configuration];
}

- (void)loadAdConfiguration {
    if ([self.adConfiguration useTracking:LoopMeTrackerName.moat]) {
        LOOMoatOptions *options = [[LOOMoatOptions alloc] init];
        options.debugLoggingEnabled = YES;
        [[LOOMoatAnalytics sharedInstance] startWithOptions:options];
        
        if (!self.moatTracker) {
            self.moatTracker = [LOOMoatWebTracker trackerWithWebComponent:self.webView];
        }
    }

    if (self.adConfiguration.creativeType == LoopMeCreativeTypeMRAID) {
        
        NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"LoopMeResources" withExtension:@"bundle"];
        if (!bundleURL) {
            [self.delegate adDisplayController:self didFailToLoadAdWithError:[LoopMeError errorForStatusCode:LoopMeErrorCodeNoResourceBundle]];
            return;
        }
        NSBundle *resourcesBundle = [NSBundle bundleWithURL:bundleURL];
        NSString *jsPath = [resourcesBundle pathForResource:@"mraid" ofType:@"js"];
        NSString *mraidjs = [NSString stringWithContentsOfFile:jsPath encoding:NSUTF8StringEncoding error:NULL];
        
        if (mraidjs) {
            mraidjs = [mraidjs stringByAppendingString:@"</script>"];
            mraidjs = [@"<script>" stringByAppendingString:mraidjs];
            
            NSMutableString *html = [self.adConfiguration.creativeContent mutableCopy];
            
            NSRange range = [html rangeOfString:@"<script>"];
            [html insertString:mraidjs atIndex:range.location];
            self.adConfiguration.creativeContent = html;
        } else {
            [self.delegate adDisplayController:self didFailToLoadAdWithError:[LoopMeError errorForStatusCode:LoopMeErrorCodeNoResourceBundle]];
            return;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.webView loadHTMLString:self.adConfiguration.creativeContent
                             baseURL:[NSURL URLWithString:kLoopMeBaseURL]];
    });
    
    self.webViewTimeOutTimer = [NSTimer scheduledTimerWithTimeInterval:kLoopMeWebViewLoadingTimeout target:self selector:@selector(cancelWebView) userInfo:nil repeats:NO];
}

- (void)displayAd {
    if ([self.adConfiguration useTracking:LoopMeTrackerName.moat]) {
        [self.moatTracker startTracking];
    }
    self.adDisplayed = YES;
    ((LoopMeVideoClientNormal *)self.videoClient).viewController = [self.delegate viewControllerForPresentation];
    self.webView.frame = self.delegate.containerView.bounds;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    CGRect adjustedFrame = [self adjustFrame:self.delegate.containerView.bounds];
    [self.videoClient adjustViewToFrame:adjustedFrame];
    
    [self.delegate.containerView addSubview:self.webView];
    [self.delegate.containerView bringSubviewToFront:self.webView];
    [(LoopMeVideoClientNormal *)self.videoClient willAppear];
    
    if (self.adConfiguration.creativeType == LoopMeCreativeTypeMRAID) {
        self.originalSize = adjustedFrame.size;
        NSString *placementType = [self.delegate isKindOfClass:[LoopMeInterstitialGeneral class]] ? @"interstitial" : @"inline";
        [self.mraidClient executeEvent:LoopMeMRAIDFunctions.setPlacementType params:@[placementType]];
        [self.mraidClient executeEvent:LoopMeMRAIDFunctions.setDefaultPosition params:@[@0, @0, @(adjustedFrame.size.width), @(adjustedFrame.size.height)]];
        
        CGSize windowSize = [[UIApplication sharedApplication] keyWindow].bounds.size;
        [self.mraidClient executeEvent:LoopMeMRAIDFunctions.setMaxSize params:@[@(windowSize.width),@(windowSize.height)]];
        [self.mraidClient executeEvent:LoopMeMRAIDFunctions.setScreenSize params:@[@(windowSize.width), @(windowSize.height)]];

        
        [self.mraidClient executeEvent:LoopMeMRAIDFunctions.stateChange params:@[LoopMeMRAIDState.defaultt]];
        [self.mraidClient executeEvent:LoopMeMRAIDFunctions.ready params:nil];
        
        self.closeButton.frame = [self frameForCloseButton:adjustedFrame];
        [self.delegate.containerView addSubview:self.closeButton];
        
        if ([self.delegate isKindOfClass:[LoopMeAdView class]]) {
            self.closeButton.alpha = 0.011;
        }
    }

    self.panWebView = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panWebView:)];
    [self.webView addGestureRecognizer:self.panWebView];
    
    self.pinchWebView = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchWebView:)];
    [self.webView addGestureRecognizer:self.pinchWebView];
}

- (void)closeAd {
    [self.JSClient executeEvent:LoopMeEvent.state forNamespace:kLoopMeNamespaceWebview param:LoopMeWebViewState.closed];
    if ([self.adConfiguration useTracking:LoopMeTrackerName.moat]) {
        [self.moatTracker stopTracking];
    }
    [self stopHandlingRequests];
    self.visible = NO;
    self.adDisplayed = NO;
    [self.webView removeGestureRecognizer:self.panWebView];
    [self.webView removeGestureRecognizer:self.pinchWebView];
    [self.webView removeFromSuperview];
}

- (void)moveView:(BOOL)hideWebView {
    [(LoopMeVideoClientNormal *)self.videoClient moveView];
    [self displayAd];
    self.webView.hidden = hideWebView;
}

- (void)expandReporting {
    self.expanded = YES;
    if (self.adConfiguration.creativeType == LoopMeCreativeTypeMRAID) {
        [self.mraidClient executeEvent:LoopMeMRAIDFunctions.stateChange params:@[LoopMeMRAIDState.expanded]];
        CGRect adjustedFrame = [self adjustFrame:self.webView.frame];
        [self.mraidClient executeEvent:LoopMeMRAIDFunctions.sizeChange params:@[@(adjustedFrame.size.width), @(adjustedFrame.size.height)]];
    }

    self.closeButton.alpha = self.adConfiguration.expandProperties.useCustomClose ? 0.011 : 1;
    [self.JSClient setFullScreenModeEnabled:YES];
}

- (void)collapseReporting {
    self.expanded = NO;
    self.closeButton.alpha = self.isUseCustomClose ? 0.011 : 1;
    [self.mraidClient executeEvent:LoopMeMRAIDFunctions.stateChange params:@[LoopMeMRAIDState.defaultt]];
    [self.JSClient setFullScreenModeEnabled:NO];
}

- (void)resizeTo:(CGSize)size {
    if (self.adConfiguration.creativeType == LoopMeCreativeTypeMRAID) {
        [self.mraidClient executeEvent:LoopMeMRAIDFunctions.sizeChange params:@[@(size.width),@(size.height)]];
        if ([[self.mraidClient getState] isEqualToString:LoopMeMRAIDState.defaultt]) {
            [self.mraidClient executeEvent:LoopMeMRAIDFunctions.stateChange params:@[LoopMeMRAIDState.resized]];
        }
        if ([self.delegate respondsToSelector:@selector(adDisplayController:willResizeAd:)]) {
            [self.delegate adDisplayController:self willResizeAd:size];
        }
    }
}

- (void)setOrientationProperties:(NSDictionary *)orientationProperties {
    if (orientationProperties) {
        _orientationProperties = orientationProperties;
    }
    BOOL allowOrientationChange = [self.orientationProperties[@"allowOrientationChange"] isEqualToString:@"true"] ? YES : NO;
    UIInterfaceOrientation preferredOrientation = [self calculatePreferredOrientstion:allowOrientationChange orientationProperties:self.orientationProperties];
    LoopMeAdOrientation adOrientation;
    if (UIInterfaceOrientationIsPortrait(preferredOrientation)) {
        adOrientation = LoopMeAdOrientationPortrait;
    } else {
        adOrientation = LoopMeAdOrientationLandscape;
    }
    
    if ([[self.delegate viewControllerForPresentation] isKindOfClass:[LoopMeInterstitialViewController class]]) {
        [(LoopMeInterstitialViewController *)[self.delegate viewControllerForPresentation] setAllowOrientationChange:allowOrientationChange];
        [(LoopMeInterstitialViewController *)[self.delegate viewControllerForPresentation] setOrientation:adOrientation];
        [(LoopMeInterstitialViewController *)[self.delegate viewControllerForPresentation] forceChangeOrientation];
    }
    
    if ([self.delegate respondsToSelector:@selector(adDisplayController:allowOrientationChange:orientation:)]) {
        [self.delegate adDisplayController:self allowOrientationChange:allowOrientationChange orientation:adOrientation];
    }
}

#pragma mark private

- (CGRect)adjustFrame:(CGRect)frame {
    BOOL isMaximizedMraid = ([self.delegate respondsToSelector:@selector(isMaximizedControllerIsPresented)] && [self.delegate performSelector:@selector(isMaximizedControllerIsPresented)]);
    if ((self.isInterstitial && [self adOrientationMatchContainer:frame]) || isMaximizedMraid) {
        frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.height, frame.size.width);
    }
    
    return frame;
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
    if ([self.JSClient shouldInterceptURL:URL]) {
        [self.JSClient executeEvent:LoopMeEvent.isNativeCallFinished forNamespace:kLoopMeNamespaceWebview param:@YES paramBOOL:YES];
        [self.JSClient processURL:URL];
        return NO;
    } else if ([self.mraidClient shouldInterceptURL:URL]){
        [self.mraidClient processURL:URL];
        return NO;
    } else if ([self shouldIntercept:URL navigationType:navigationType]) {
        [self interceptURL:URL];
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (self.adConfiguration.creativeType == LoopMeCreativeTypeMRAID) {
        [self.mraidClient setSupports];
        [self setOrientation:[self.mraidClient getOrientationProperties] forConfiguration:self.adConfiguration];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    LoopMeLogDebug(@"WebView received an error %@", error);
    if (error.code == -1004) {
        if ([self.delegate respondsToSelector:@selector(adDisplayController:didFailToLoadAdWithError:)]) {
            [self.delegate adDisplayController:self didFailToLoadAdWithError:error];
        }
    }
}

#pragma mark - JSClientDelegate 

- (UIWebView *)webViewTransport {
    return self.webView;
}

- (id<LoopMeVideoCommunicatorProtocol>)videoCommunicator {
    return self.videoClient;
}

- (void)JSClientDidReceiveSuccessCommand:(LoopMeJSClient *)client {
    LoopMeLogInfo(@"Ad was successfully loaded");
    [self.webViewTimeOutTimer invalidate];
    self.webViewTimeOutTimer = nil;
    if ([self.delegate respondsToSelector:@selector(adDisplayControllerDidFinishLoadingAd:)]) {
        [self.delegate adDisplayControllerDidFinishLoadingAd:self];
    }
}

- (void)JSClientDidReceiveFailCommand:(LoopMeJSClient *)client {
    NSError *error = [LoopMeError errorForStatusCode:LoopMeErrorCodeSpecificHost];
    LoopMeLogInfo(@"Ad failed to load: %@", error);
    [self.webViewTimeOutTimer invalidate];
    self.webViewTimeOutTimer = nil;
    if ([self.delegate respondsToSelector:@selector(adDisplayController:didFailToLoadAdWithError:)]) {
        [self.delegate adDisplayController:self didFailToLoadAdWithError:error];
    }
}

- (void)JSClientDidReceiveCloseCommand:(LoopMeJSClient *)client {
    if ([self.delegate respondsToSelector:@selector(adDisplayControllerShouldCloseAd:)]) {
        [self.delegate adDisplayControllerShouldCloseAd:self];
    }
}

- (void)JSClientDidReceiveVibrateCommand:(LoopMeJSClient *)client {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)JSClientDidReceiveFulLScreenCommand:(LoopMeJSClient *)client fullScreen:(BOOL)expand {
    if (self.isFirstCallToExpand) {
        expand = NO;
        self.firstCallToExpand = NO;
    }
    
    if (expand) {
        if ([self.delegate respondsToSelector:@selector(adDisplayControllerWillExpandAd:)]) {
            [self.videoClient setGravity:AVLayerVideoGravityResizeAspect];
            [self.delegate adDisplayControllerWillExpandAd:self];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(adDisplayControllerWillCollapse:)]) {
            [self.delegate adDisplayControllerWillCollapse:self];
        }
    }
}

#pragma mark - MRAIDClientDelegate

- (void)mraidClient:(LoopMeMRAIDClient *)client shouldOpenURL:(NSURL *)URL {
    if ([self.delegate respondsToSelector:@selector(adDisplayControllerDidReceiveTap:)]) {
        [self.delegate adDisplayControllerDidReceiveTap:self];
    }
    [self interceptURL:URL];
}

- (void)mraidClient:(LoopMeMRAIDClient *)client useCustomClose:(BOOL)useCustomCLose {
    self.useCustomClose = useCustomCLose;
}

- (void)mraidClient:(LoopMeMRAIDClient *)client sholdPlayVideo:(NSURL *)URL {
    [(LoopMeVideoClientNormal *)self.videoClient playVideo:URL];
}

- (void)mraidClient:(LoopMeMRAIDClient *)client setOrientationProperties:(NSDictionary *)orientationProperties {
    [self setOrientationProperties:orientationProperties];
}

- (void)mraidClientDidReceiveCloseCommand:(LoopMeMRAIDClient *)client {
    if ([[self.mraidClient getState] isEqualToString:LoopMeMRAIDState.resized]) {
        [self resizeTo:self.originalSize];
        [self.mraidClient executeEvent:LoopMeMRAIDFunctions.stateChange params:@[LoopMeMRAIDState.defaultt]];
        return;
    }
    if ([self.delegate respondsToSelector:@selector(adDisplayControllerShouldCloseAd:)]) {
        [self.delegate adDisplayControllerShouldCloseAd:self];
    }
}

- (void)mraidClientDidReceiveExpandCommand:(LoopMeMRAIDClient *)client {
    if ([self.delegate respondsToSelector:@selector(adDisplayControllerWillExpandAd:)]) {
        [self.delegate adDisplayControllerWillExpandAd:self];
    }
}

- (void)mraidClientDidResizeAd:(LoopMeMRAIDClient *)client {
    NSDictionary *resizeProperties = [self.mraidClient getResizeProperties];
    CGFloat width = [[resizeProperties objectForKey:@"width"] floatValue];
    CGFloat height = [[resizeProperties objectForKey:@"height"] floatValue];
    CGSize newSize = CGSizeMake(width, height);
    
    [self resizeTo:newSize];
}

#pragma mark - VideoClientDelegate

- (UIViewController *)viewControllerForPresentation {
    return [self.delegate viewControllerForPresentation];
}

- (id<LoopMeJSCommunicatorProtocol>)JSCommunicator {
    return self.JSClient;
}

- (void)videoClientDidReachEnd:(LoopMeVideoClient *)client {
    LoopMeLogInfo(@"Video ad did reach end");
    if ([self.delegate respondsToSelector:
         @selector(adDisplayControllerVideoDidReachEnd:)]) {
        [self.delegate adDisplayControllerVideoDidReachEnd:self];
    }
}

- (void)videoClient:(LoopMeVideoClient *)client didFailToLoadVideoWithError:(NSError *)error {
    LoopMeLogInfo(@"Did fail to load video ad");
    if ([self.delegate respondsToSelector:
         @selector(adDisplayController:didFailToLoadAdWithError:)]) {
        [self.delegate adDisplayController:self didFailToLoadAdWithError:error];
    }
}

- (void)videoClient:(LoopMeVideoClient *)client setupView:(UIView *)view {
    view.frame = [self adjustFrame:self.delegate.containerView.bounds];
    [[self.delegate containerView] insertSubview:view belowSubview:self.webView];
}

- (void)videoClientDidBecomeActive:(LoopMeVideoClient *)client {
    [self layoutSubviews];
    if (/*!self.isDestIsShown && ![self.videoClient playerReachedEnd] && !self.isEndCardClicked && */self.visible) {
        [self.videoClient play];
    }
}

@end
