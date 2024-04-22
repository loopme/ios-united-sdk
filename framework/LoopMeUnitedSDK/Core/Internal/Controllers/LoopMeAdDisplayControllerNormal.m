//
//  LoopMeAdDisplayController.m
//  LoopMeSDK
//
//  Created by Dmitriy Lihachov on 8/21/12.
//  Copyright (c) 2013 LoopMe. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import <LoopMeUnitedSDK/LoopMeUnitedSDK-Swift.h>

#import "LoopMeOMIDVideoEventsWrapper.h"
#import "LoopMeIASWrapper.h"
#import "LoopMeAdDisplayControllerNormal.h"
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
#import "LoopMeOMIDWrapper.h"
#import "LoopMeSDK.h"
#import "LoopMeMRAIDScriptMessageHandler.h"

NSString * const kLoopMeShakeNotificationName = @"DeviceShaken";

@interface LoopMeAdDisplayControllerNormal ()
<
    WKNavigationDelegate,
    WKUIDelegate,
    LoopMeVideoClientDelegate,
    LoopMeJSClientDelegate,
    LoopMeMRAIDClientDelegate
>

@property (nonatomic, strong) LoopMeCloseButton *closeButton;
@property (nonatomic, strong) LoopMeJSClient *JSClient;
@property (nonatomic, strong) LoopMeMRAIDClient *mraidClient;
@property (nonatomic, strong) LoopMeMRAIDScriptMessageHandler *mraidScriptMessageHandler;
@property (nonatomic, strong) NSDictionary *orientationProperties;
@property (nonatomic, assign) CGSize originalSize;

@property (nonatomic, assign, getter=isFirstCallToExpand) BOOL firstCallToExpand;
@property (nonatomic, assign, getter=isUseCustomClose) BOOL useCustomClose;
@property (nonatomic, assign, getter=isExpanded) BOOL expanded;

@property (nonatomic, assign) CGPoint prevLoaction;
@property (nonatomic, strong) UIPanGestureRecognizer *panWebView;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchWebView;

@property (nonatomic, assign) BOOL adDisplayed;
@property (nonatomic, strong) LoopMeIASWrapper *iasWarpper;

@property (nonatomic, strong) OMIDLoopmeAdSession* omidSession;
@property (nonatomic, strong) OMIDLoopmeAdEvents *omidAdEvents;
@property (nonatomic, strong) LoopMeOMIDWrapper *omidWrapper;

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
    if (!self.adDisplayed || super.visible == visible) {
        return ;
    }

    super.visible = _forceHidden ? NO : visible;
    
    if (self.adConfiguration.creativeType == LoopMeCreativeTypeMraid) {
        [self.mraidClient executeEvent: LoopMeMRAIDFunctions.viewableChange
                                params: @[super.visible ? @"true" : @"false"]];
    }

    [self.JSClient executeEvent: LoopMeEvent.state
                   forNamespace: kLoopMeNamespaceWebview
                          param: (visible && !_forceHidden) ? LoopMeWebViewState.visible : LoopMeWebViewState.hidden];
    
}

- (void)setVisibleNoJS:(BOOL)visibleNoJS {
    if (_visibleNoJS == visibleNoJS) {
        return ;
    }
    _visibleNoJS = visibleNoJS;
    if (self.adConfiguration.creativeType == LoopMeCreativeTypeMraid) {
        [self.mraidClient executeEvent: LoopMeMRAIDFunctions.viewableChange
                                params: @[visibleNoJS ? @"true" : @"false"]];
    }
    if (_visibleNoJS) {
        [self.videoClient play];
    } else {
        [self.videoClient pause];
    }
}

- (UIButton *)closeButton {
    if (_closeButton) {
        return _closeButton;
    }
    _closeButton = [[LoopMeCloseButton alloc] initWithFrame: CGRectMake(0, 0, 50, 50)];
    _closeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    [_closeButton addTarget: self
                     action: @selector(mraidClientDidReceiveCloseCommand:)
           forControlEvents: UIControlEventTouchUpInside];
    return _closeButton;
}

- (void)setUseCustomClose:(BOOL)useCustomClose {
    if (self.isExpanded) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.useCustomClose = useCustomClose;
        if ([self.delegate isKindOfClass:[LoopMeAdView class]]) {
            self.closeButton.alpha = 0.0;
        } else {
            self.closeButton.alpha = useCustomClose ? 0.011 : 1;
        }
    });
}

#pragma mark - Life Cycle

- (void)dealloc {
    [self.omidSession finish];
    [self removeWebView];
    [self invalidateTimer];
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: kLoopMeShakeNotificationName
                                                  object: nil];
}

- (instancetype)initWithDelegate:(id<LoopMeAdDisplayControllerDelegate>)delegate {
    self = [super initWithDelegate: delegate];
    if (!self) {
        return self;
    }

    self.delegate = delegate;
    _JSClient = [[LoopMeJSClient alloc] initWithDelegate: self];
    _mraidClient = [[LoopMeMRAIDClient alloc] initWithDelegate: self];
    _iasWarpper = [[LoopMeIASWrapper alloc] init];
    _omidWrapper = [[LoopMeOMIDWrapper alloc] init];
    

    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(deviceShaken)
                                                 name: kLoopMeShakeNotificationName
                                               object: nil];
    _firstCallToExpand = YES;
    return self;
}

#pragma mark - Private

- (void)initWebView {
    self.mraidScriptMessageHandler = [[LoopMeMRAIDScriptMessageHandler alloc] init];
    self.mraidScriptMessageHandler.mraidClient = self.mraidClient;

    WKUserContentController *controller = [[WKUserContentController alloc] init];
    [controller addScriptMessageHandler: self.mraidScriptMessageHandler
                                   name: @"mraid"];

    NSBundle *resourcesBundle = [LoopMeSDK resourcesBundle];
    if (!resourcesBundle) {
        @throw [NSException exceptionWithName: @"NoBundleResource"
                                       reason: @"No loopme resourse bundle"
                                     userInfo: nil];
    }
    NSString *jsPath = [resourcesBundle pathForResource: @"mraid.js"
                                                 ofType: @"ignore"];
    NSString *mraidjs = [NSString stringWithContentsOfFile: jsPath
                                                  encoding: NSUTF8StringEncoding
                                                     error: NULL];
    WKUserScript *script = [[WKUserScript alloc] initWithSource: mraidjs
                                                  injectionTime: WKUserScriptInjectionTimeAtDocumentStart
                                               forMainFrameOnly: NO];
    [controller addUserScript: script];
    
    [self initializeWebViewWithContentController: controller];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
}

- (void)deviceShaken {
    [self.JSClient setShake];
}

- (void)interceptURL:(NSURL *)URL {
    [self.destinationDisplayClient displayDestinationWithURL: URL];
}

- (void)panWebView:(UIPanGestureRecognizer *)recognizer {
    CGPoint currentLocation = [recognizer locationInView: self.webView];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.prevLoaction = currentLocation;
    }
    
    LoopMe360ViewController *vc = [(LoopMeVideoClientNormal *)self.videoClient viewController360];
    [vc pan: currentLocation prevLocation: self.prevLoaction];
    self.prevLoaction = currentLocation;
}

- (void)pinchWebView:(UIPinchGestureRecognizer *)recognizer {
    LoopMe360ViewController *vc = [(LoopMeVideoClientNormal *)self.videoClient viewController360];
    [vc handlePinchGesture: recognizer];
}

- (void)setOrientation:(NSDictionary *)orientationProperties forConfiguration:(LoopMeAdConfiguration *)configuration {
    if (!orientationProperties) {
        return ;
    }
    configuration.allowOrientationChange = [orientationProperties[@"allowOrientationChange"] boolValue];
    if ([orientationProperties[@"forceOrientation"] isEqualToString: @"portrait"]) {
        configuration.adOrientation = LoopMeAdOrientationPortrait;
    } else if ([orientationProperties[@"forceOrientation"] isEqualToString: @"landscape"]) {
        configuration.adOrientation = LoopMeAdOrientationLandscape;
    }
}

- (void)setExpandProperties:(NSDictionary *)properties forConfiguration:(LoopMeAdConfiguration *)configuration {
    if (!properties) {
        return ;
    }
    LoopMeMRAIDExpandProperties *expandProperties = [[LoopMeMRAIDExpandProperties alloc] init];
    expandProperties.height = [properties[@"height"] intValue];
    expandProperties.width = [properties[@"width"] intValue];
    expandProperties.useCustomClose = [properties[@"useCustomClose"] boolValue];
    configuration.expandProperties = expandProperties;
}

- (CGRect)frameForCloseButton:(CGRect)superviewFrame {
    return CGRectMake(superviewFrame.size.width - 50, 0, 50, 50);
}

- (UIInterfaceOrientation)calculatePreferredOrientstion:(BOOL)allowOrientationChange orientationProperties:(NSDictionary *)orientationProperties {

    if (allowOrientationChange) {
        return [[UIApplication sharedApplication] statusBarOrientation];
    }
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if ([orientationProperties[@"forceOrientation"] isEqualToString: @"portrait"]) {
        // this will accomodate both portrait and portrait upside down
        return UIInterfaceOrientationIsPortrait(orientation) ? orientation : UIInterfaceOrientationPortrait;
    }
    if ([orientationProperties[@"forceOrientation"] isEqualToString: @"landscape"]) {
        // this will accomodate both landscape left and landscape right
        return UIInterfaceOrientationIsLandscape(orientation) ? orientation : UIInterfaceOrientationLandscapeLeft;
    }
    return orientation;
}

- (void)invalidateTimer {
    [self.webViewTimeOutTimer invalidate];
    self.webViewTimeOutTimer = nil;
}

#pragma mark - Public

- (void)setExpandProperties:(LoopMeAdConfiguration *)configuration {
    [self setExpandProperties: self.mraidClient.expandProperties
             forConfiguration: configuration];
}

- (void)loadAdConfiguration {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initWebView];
        if ([self.adConfiguration useTracking: LoopMeTrackerNameIas]) {
            [self.iasWarpper initWithPartnerVersion: LOOPME_SDK_VERSION
                                       creativeType: self.adConfiguration.creativeType
                                    adConfiguration: self.adConfiguration];
            [self.iasWarpper registerAdView: self.webView];
        }
        

        NSError *error;
        self.adConfiguration.creativeContent = [self.omidWrapper injectScriptContentIntoHTML:self.adConfiguration.creativeContent error:&error];
        [self.webView loadHTMLString: self.adConfiguration.creativeContent
                             baseURL: [NSURL URLWithString: kLoopMeBaseURL]];
        self.webViewTimeOutTimer = [NSTimer scheduledTimerWithTimeInterval: kLoopMeWebViewLoadingTimeout
                                                                    target: self
                                                                  selector: @selector(cancelWebView)
                                                                  userInfo: nil
                                                                   repeats: NO];
    });
}

- (void)displayAd {
    if ([self.adConfiguration useTracking: LoopMeTrackerNameIas]) {
        [self.iasWarpper recordReadyEvent];
        [self.iasWarpper recordAdLoadedEvent];
    }
    

    
    self.adDisplayed = YES;
    ((LoopMeVideoClientNormal *)self.videoClient).viewController = [self.delegate viewControllerForPresentation];
    CGRect adjustedFrame = [self adjustFrame: self.delegate.containerView.bounds];
    [self.videoClient adjustViewToFrame: adjustedFrame];
    
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // TODO: May be we can store 'self.delegate.containerView' and use it everywhere to reduce repetition
    if ([self.delegate.containerView isKindOfClass: [LoopMeAdView class]]) {
        self.delegate.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    [self.delegate.containerView addSubview: self.webView];
    [self.delegate.containerView bringSubviewToFront: self.webView];
    [(LoopMeVideoClientNormal *)self.videoClient willAppear];
    
    if (@available(iOS 11.0, *)) {
        [[[self.webView leadingAnchor] constraintEqualToAnchor:self.delegate.containerView.safeAreaLayoutGuide.leadingAnchor] setActive:YES];
        [[[self.webView trailingAnchor] constraintEqualToAnchor:self.delegate.containerView.safeAreaLayoutGuide.trailingAnchor] setActive:YES];
        [[[self.webView topAnchor] constraintEqualToAnchor:self.delegate.containerView.safeAreaLayoutGuide.topAnchor] setActive:YES];
        [[[self.webView bottomAnchor] constraintEqualToAnchor:self.delegate.containerView.safeAreaLayoutGuide.bottomAnchor] setActive:YES];
    } else {
        // Fallback on earlier versions
        [[[self.webView leadingAnchor] constraintEqualToAnchor:self.delegate.containerView.leadingAnchor] setActive:YES];
        [[[self.webView trailingAnchor] constraintEqualToAnchor:self.delegate.containerView.trailingAnchor] setActive:YES];
        [[[self.webView topAnchor] constraintEqualToAnchor:self.delegate.containerView.topAnchor] setActive:YES];
        [[[self.webView bottomAnchor] constraintEqualToAnchor:self.delegate.containerView.bottomAnchor] setActive:YES];
    }
    
    if (self.adConfiguration.creativeType == LoopMeCreativeTypeMraid) {
        self.originalSize = adjustedFrame.size;
        NSString *placementType = [self.delegate isKindOfClass: [LoopMeInterstitialGeneral class]] ? @"interstitial" : @"inline";
        [self.mraidClient executeEvent: LoopMeMRAIDFunctions.setPlacementType
                                params: @[placementType]];
        [self.mraidClient executeEvent: LoopMeMRAIDFunctions.setDefaultPosition
                                params: @[@0, @0, @(adjustedFrame.size.width), @(adjustedFrame.size.height)]];
        
        CGSize windowSize = [[UIApplication sharedApplication] keyWindow].bounds.size;
        [self.mraidClient executeEvent: LoopMeMRAIDFunctions.setMaxSize
                                params: @[@(windowSize.width), @(windowSize.height)]];
        [self.mraidClient executeEvent: LoopMeMRAIDFunctions.setScreenSize
                                params: @[@(windowSize.width), @(windowSize.height)]];
        
        [self.mraidClient executeEvent: LoopMeMRAIDFunctions.stateChange
                                params: @[LoopMeMRAIDState.defaultt]];
        [self.mraidClient executeEvent: LoopMeMRAIDFunctions.ready
                                params: nil];
        
        self.closeButton.frame = [self frameForCloseButton: adjustedFrame];
        [self.delegate.containerView addSubview: self.closeButton];
        
        if (@available(iOS 11.0, *)) {
            self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
            UILayoutGuide *guide = [self.delegate.containerView safeAreaLayoutGuide];
            [[[guide topAnchor] constraintEqualToAnchor: self.closeButton.topAnchor
                                               constant: -8] setActive: YES];
            [[[guide trailingAnchor] constraintEqualToSystemSpacingAfterAnchor: self.closeButton.trailingAnchor
                                                                    multiplier: 1] setActive: YES];
        }
    }
    
    self.panWebView = [[UIPanGestureRecognizer alloc] initWithTarget: self
                                                              action: @selector(panWebView:)];
    [self.webView addGestureRecognizer: self.panWebView];
    self.pinchWebView = [[UIPinchGestureRecognizer alloc] initWithTarget: self
                                                                  action: @selector(pinchWebView:)];
    [self.webView addGestureRecognizer:self.pinchWebView];
    
    //AVID
    [self.iasWarpper recordAdImpressionEvent];
    //OMSDK
    NSError *impError;
    [self.omidAdEvents impressionOccurredWithError: &impError];
}

- (void)closeAd {
    //OMSDK
    [self.omidSession finish];
    self.omidSession = nil;
    if ([self.adConfiguration useTracking: LoopMeTrackerNameIas]) {
        [self.iasWarpper clean];
        [self.iasWarpper unregisterAdView: self.webView];
        [self.iasWarpper endSession];
    }
    
    [self.JSClient executeEvent: LoopMeEvent.state
                   forNamespace: kLoopMeNamespaceWebview
                          param: LoopMeWebViewState.closed];
    [self stopHandlingRequests];
    self.visible = NO;
    self.adDisplayed = NO;
    [self.videoClient cancel];
    [self removeWebView];
}

- (void)removeWebView {
    [self.webView removeGestureRecognizer: self.panWebView];
    [self.webView removeGestureRecognizer: self.pinchWebView];
    [self.webView loadHTMLString: @"about:blank" baseURL: nil];
    [self.webView stopLoading];
    [self.webView removeFromSuperview];
    [self.webView.configuration.userContentController removeAllUserScripts];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName: @"mraid"];
}

- (void)moveView:(BOOL)hideWebView {
    [(LoopMeVideoClientNormal *)self.videoClient moveView];
    [self displayAd];
    self.webView.hidden = hideWebView;
}

- (void)expandReporting {
    self.expanded = YES;
    if (self.adConfiguration.creativeType == LoopMeCreativeTypeMraid) {
        [self.mraidClient executeEvent: LoopMeMRAIDFunctions.stateChange
                                params: @[LoopMeMRAIDState.expanded]];
        CGRect adjustedFrame = [self adjustFrame: self.webView.frame];
        [self.mraidClient executeEvent: LoopMeMRAIDFunctions.sizeChange
                                params: @[@(adjustedFrame.size.width), @(adjustedFrame.size.height)]];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.closeButton.alpha = self.adConfiguration.expandProperties.useCustomClose ? 0.011 : 1;
    });
    [self.JSClient setFullScreenModeEnabled: YES];
}

- (void)collapseReporting {
    self.expanded = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.closeButton.alpha = ([self.delegate isKindOfClass: [LoopMeAdView class]] || self.isUseCustomClose) ? 0.0 : 1;
    });
    [self.mraidClient executeEvent: LoopMeMRAIDFunctions.stateChange
                            params: @[LoopMeMRAIDState.defaultt]];
    [self.JSClient setFullScreenModeEnabled: NO];
}

- (void)resizeTo:(CGSize)size {
    if (self.adConfiguration.creativeType != LoopMeCreativeTypeMraid) {
        return ;
    }
    [self.mraidClient executeEvent: LoopMeMRAIDFunctions.sizeChange params: @[@(size.width), @(size.height)]];
    
    if ([self.mraidClient.state isEqualToString: LoopMeMRAIDState.defaultt]) {
        [self.mraidClient executeEvent: LoopMeMRAIDFunctions.stateChange params: @[LoopMeMRAIDState.resized]];
    }
    
    if ([self.delegate respondsToSelector: @selector(adDisplayController: willResizeAd:)]) {
        [self.delegate adDisplayController: self willResizeAd: size];
    }
}

- (void)setOrientationProperties:(NSDictionary *)orientationProperties {
    if (orientationProperties) {
        _orientationProperties = orientationProperties;
    }
    BOOL allowOrientationChange = [self.orientationProperties[@"allowOrientationChange"] isEqualToString: @"true"];
    UIInterfaceOrientation preferredOrientation = [self calculatePreferredOrientstion: allowOrientationChange
                                                                orientationProperties: self.orientationProperties];
    LoopMeAdOrientation adOrientation;
    adOrientation = UIInterfaceOrientationIsPortrait(preferredOrientation) ? LoopMeAdOrientationPortrait : LoopMeAdOrientationLandscape;
    
    if ([[self.delegate viewControllerForPresentation] isKindOfClass:[LoopMeInterstitialViewController class]]) {
        LoopMeInterstitialViewController *controller = (LoopMeInterstitialViewController *)[self.delegate viewControllerForPresentation];
        [controller setAllowOrientationChange: allowOrientationChange];
        [controller setOrientation: adOrientation];
        [controller forceChangeOrientation];
    }
    
    if ([self.delegate respondsToSelector: @selector(adDisplayController:allowOrientationChange:orientation:)]) {
        [self.delegate adDisplayController: self
                    allowOrientationChange: allowOrientationChange
                               orientation: adOrientation];
    }
}

#pragma mark private

- (CGRect)adjustFrame:(CGRect)frame {
    BOOL isMaximizedMraid = ([self.delegate respondsToSelector: @selector(isMaximizedControllerIsPresented)] && [self.delegate performSelector: @selector(isMaximizedControllerIsPresented)]);
    
    BOOL isPortrait = self.adConfiguration.isPortrait;
    BOOL isVertical = frame.size.width < frame.size.height;
    BOOL isAdOrientationMatchContainer = (!isPortrait && isVertical) || (isPortrait && !isVertical);
    
    if ((self.isInterstitial && isAdOrientationMatchContainer) || isMaximizedMraid) {
        frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.height, frame.size.width);
    }
    
    return frame;
}

#pragma mark - WKDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSURL *URL = [[navigationAction request] URL];
    
    if ([self.JSClient shouldInterceptURL: URL]) {
        [self.JSClient processURL: URL];
        decisionHandler(NO);
        return;
    }
    if ([self.mraidClient shouldInterceptURL: URL]) {
        decisionHandler(NO);
        return;
    }
    if ([self shouldIntercept: URL navigationType: navigationAction.navigationType]) {
        [self interceptURL: URL];
        decisionHandler(NO);
        return;
    }
    decisionHandler(YES);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if (self.adConfiguration.creativeType == LoopMeCreativeTypeMraid) {
        [self.mraidClient setSupports];
        [self.delegate adDisplayControllerDidFinishLoadingAd: self];
    }

    //OMSDK
    if (self.omidSession != nil) return;
    
    NSError *error;
    self.omidSession = [self.omidWrapper sessionForHTML: webView error: &error];
    if (error) {
        // TODO: Fill empty case
    }
    // Set the view on which to track viewability
    self.omidSession.mainAdView = webView;
    [self.omidSession addFriendlyObstruction: self.closeButton
                                     purpose: OMIDFriendlyObstructionCloseAd
                              detailedReason: nil
                                       error: &error];
    // Start session
    [self.omidSession start];
    
    NSError *adEvtsError;
    self.omidAdEvents = [[OMIDLoopmeAdEvents alloc] initWithAdSession: self.omidSession
                                                                error: &adEvtsError];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    LoopMeLogDebug(@"WebView received an error %@", error);
    if (error.code == -1004 && [self.delegate respondsToSelector: @selector(adDisplayController:didFailToLoadAdWithError:)]) {
        [self.delegate adDisplayController: self didFailToLoadAdWithError: error];
    }
}

#pragma mark - JSClientDelegate

- (WKWebView *)webViewTransport {
    return self.webView;
}

- (id<LoopMeVideoCommunicatorProtocol>)videoCommunicator {
    return self.videoClient;
}

- (void)JSClientDidReceiveSuccessCommand:(LoopMeJSClient *)client {
    LoopMeLogInfo(@"Ad was successfully loaded");
    [self invalidateTimer];
    
    [self.omidAdEvents loadedWithError:nil];
    
    if ([self.delegate respondsToSelector: @selector(adDisplayControllerDidFinishLoadingAd:)]) {
        [self.delegate adDisplayControllerDidFinishLoadingAd: self];
    }
}

- (void)JSClientDidReceiveFailCommand:(LoopMeJSClient *)client {
    NSError *error = [LoopMeError errorForStatusCode: LoopMeErrorCodeSpecificHost];
    LoopMeLogInfo(@"Ad failed to load: %@", error);
    [self invalidateTimer];
    if ([self.delegate respondsToSelector :@selector(adDisplayController:didFailToLoadAdWithError:)]) {
        [self.delegate adDisplayController: self didFailToLoadAdWithError: error];
    }
}

- (void)JSClientDidReceiveCloseCommand:(LoopMeJSClient *)client {
    [self.iasWarpper recordAdUserCloseEvent];
    if ([self.delegate respondsToSelector: @selector(adDisplayControllerShouldCloseAd:)]) {
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
        if ([self.delegate respondsToSelector: @selector(adDisplayControllerWillExpandAd:)]) {
            [self.videoClient setGravity: AVLayerVideoGravityResizeAspect];
            [self.delegate adDisplayControllerWillExpandAd: self];
        }
    } else {
        if ([self.delegate respondsToSelector: @selector(adDisplayControllerWillCollapse:)]) {
            [self.delegate adDisplayControllerWillCollapse: self];
        }
    }
}

#pragma mark - MRAIDClientDelegate

- (void)mraidClient:(LoopMeMRAIDClient *)client shouldOpenURL:(NSURL *)URL {
    if ([self.delegate respondsToSelector: @selector(adDisplayControllerDidReceiveTap:)]) {
        [self.delegate adDisplayControllerDidReceiveTap: self];
    }
    [self.iasWarpper recordAdClickThruEvent];
    [self interceptURL: URL];
}

- (void)mraidClient:(LoopMeMRAIDClient *)client useCustomClose:(BOOL)useCustomCLose {
    /// If banner (class LoopMeAdView) then do not show close button, else show close button
    self.useCustomClose = [self.delegate isMemberOfClass:[LoopMeAdView class]];
    if (!self.isUseCustomClose) {
        [self.iasWarpper registerFriendlyObstruction: self.closeButton];
    }
}

- (void)mraidClient:(LoopMeMRAIDClient *)client sholdPlayVideo:(NSURL *)URL {
    [(LoopMeVideoClientNormal *)self.videoClient playVideo: URL];
}

- (void)mraidClient:(LoopMeMRAIDClient *)client setOrientationProperties:(NSDictionary *)orientationProperties {
    [self setOrientationProperties: orientationProperties];
}

- (void)mraidClientDidReceiveCloseCommand:(LoopMeMRAIDClient *)client {
    NSString *state = self.mraidClient.state;
    
    if ([state isEqualToString: LoopMeMRAIDState.resized]) {
        [self resizeTo: self.originalSize];
        [self.mraidClient executeEvent: LoopMeMRAIDFunctions.stateChange
                                params: @[LoopMeMRAIDState.defaultt]];
        return;
    }
    
    [self.iasWarpper recordAdUserCloseEvent];
    
    if ([self.delegate respondsToSelector: @selector(adDisplayControllerShouldCloseAd:)]) {
        [self.delegate adDisplayControllerShouldCloseAd: self];
    }
    // TODO: Why this code repeated twice?
    if ([state isEqualToString: LoopMeMRAIDState.resized]) {
        [self resizeTo: self.originalSize];
        [self.mraidClient executeEvent: LoopMeMRAIDFunctions.stateChange
                                params: @[LoopMeMRAIDState.defaultt]];
        return;
    }
    
    [self.iasWarpper recordAdUserCloseEvent];
}

- (void)mraidClientDidReceiveExpandCommand:(LoopMeMRAIDClient *)client {
    if ([self.delegate respondsToSelector: @selector(adDisplayControllerWillExpandAd:)]) {
        [self.delegate adDisplayControllerWillExpandAd: self];
    }
}

- (void)mraidClientDidResizeAd:(LoopMeMRAIDClient *)client {
    NSDictionary *resizeProperties = self.mraidClient.resizeProperties;
    CGFloat width = [[resizeProperties objectForKey: @"width"] floatValue];
    CGFloat height = [[resizeProperties objectForKey: @"height"] floatValue];
    [self resizeTo: CGSizeMake(width, height)];
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
    [self.iasWarpper recordAdCompleteEvent];
    if ([self.delegate respondsToSelector: @selector(adDisplayControllerVideoDidReachEnd:)]) {
        [self.delegate adDisplayControllerVideoDidReachEnd: self];
    }
}

- (void)videoClient:(LoopMeVideoClient *)client didFailToLoadVideoWithError:(NSError *)error {
    LoopMeLogInfo(@"Did fail to load video ad");
    if ([self.delegate respondsToSelector: @selector(adDisplayController:didFailToLoadAdWithError:)]) {
        [self.delegate adDisplayController: self didFailToLoadAdWithError: error];
    }
}

- (void)videoClient:(LoopMeVideoClient *)client setupView:(UIView *)view {
    view.frame = [self adjustFrame: self.delegate.containerView.bounds];
    [[self.delegate containerView] insertSubview: view belowSubview: self.webView];
}

- (void)videoClientDidBecomeActive:(LoopMeVideoClient *)client {
    [self layoutSubviews];
    if (self.visible) {
        [self.videoClient play];
    }
}

#pragma mark - Override

- (void)destinationDisplayControllerWillPresentModal:(LoopMeDestinationDisplayController *)destinationDisplayController {
    //AVID
    [self.iasWarpper recordAdClickThruEvent];
    [super destinationDisplayControllerWillPresentModal: destinationDisplayController];
}

@end
