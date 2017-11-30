//
//  LoopMeAdDisplayController.m
//  Tester
//
//  Created by Bohdan on 5/8/17.
//  Copyright © 2017 LoopMe. All rights reserved.
//

#import "LoopMeAdDisplayController.h"
#import "LoopMeDestinationDisplayController.h"
#import "LoopMeAdConfiguration.h"
#import "LoopMeAdWebView.h"
#import "LoopMeError.h"
#import "LoopMeLogging.h"

@interface LoopMeAdDisplayController ()

@end

@implementation LoopMeAdDisplayController

- (LoopMeDestinationDisplayController *)destinationDisplayClient {
    if (_destinationDisplayClient == nil) {
        _destinationDisplayClient = [LoopMeDestinationDisplayController controllerWithDelegate:self];
    }
    return _destinationDisplayClient;
}

#pragma mark - Life Cycle

- (void)dealloc {
    [_webViewTimeOutTimer invalidate];
    _webViewTimeOutTimer = nil;
    [self stopHandlingRequests];
}

- (instancetype)initWithDelegate:(id<LoopMeAdDisplayControllerDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _destinationDisplayClient = [LoopMeDestinationDisplayController controllerWithDelegate:self];
        //if frame is zero WebView display content incorrect
        _webView = [[LoopMeAdWebView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    }
    return self;
}

#pragma mark - Private

- (BOOL)shouldIntercept:(NSURL *)URL
         navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        if ([self.delegate respondsToSelector:@selector(adDisplayControllerDidReceiveTap:)]) {
            [self.delegate adDisplayControllerDidReceiveTap:self];
        }
        return YES;
    }
    return NO;
}

- (void)cancelWebView {
    [self.webView stopLoading];
    
    NSError *error = [LoopMeError errorForStatusCode:LoopMeErrorCodeHTMLRequestTimeOut];
    if ([self.delegate respondsToSelector:@selector(adDisplayController:didFailToLoadAdWithError:)]) {
        LoopMeLogInfo(@"Ad failed to load: %@", error);
        [self.delegate adDisplayController:self didFailToLoadAdWithError:error];
    }
}

#pragma mark - Public

- (void)setAdConfiguration:(LoopMeAdConfiguration *)configuration {
    if (configuration && configuration != _adConfiguration) {
        _adConfiguration = configuration;
    }
}

- (void)loadAdConfiguration {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)displayAd {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)closeAd {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)layoutSubviews {
    [self.videoClient adjustViewToFrame:self.webView.bounds];
}

- (void)layoutSubviewsToFrame:(CGRect)frame {
    [self.videoClient adjustViewToFrame:frame];
}

- (void)stopHandlingRequests {
//    [self.destinationDisplayClient cancel];
    self.destinationDisplayClient = nil;
//    [self.videoClient cancel];
    self.videoClient = nil;
    self.destinationDisplayClient = nil;
    [self.webViewTimeOutTimer invalidate];
}


- (void)expandReporting {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)collapseReporting {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}


#pragma mark - LoopMeDestinationDisplayControllerDelegate

- (UIViewController *)viewControllerForPresentingModalView {
    return [self.delegate viewControllerForPresentation];
}

- (void)destinationDisplayControllerWillLeaveApplication:(LoopMeDestinationDisplayController *)destinationDisplayController {
    if ([self.delegate respondsToSelector:@selector(adDisplayControllerWillLeaveApplication:)]) {
        [self.delegate adDisplayControllerWillLeaveApplication:self];
    }
}

- (void)destinationDisplayControllerWillPresentModal:(LoopMeDestinationDisplayController *)destinationDisplayController {
    self.visible = NO;
    self.destinationIsPresented = YES;
}

- (void)destinationDisplayControllerDidDismissModal:(LoopMeDestinationDisplayController *)destinationDisplayController {
    self.destinationIsPresented = NO;
    self.visible = YES;
    if (![self.videoClient playerReachedEnd] && !self.isEndCardClicked) {
        [self.videoClient play];
    }
}

- (NSString *)appKey {
    return self.adConfiguration.appKey;
}

@end
