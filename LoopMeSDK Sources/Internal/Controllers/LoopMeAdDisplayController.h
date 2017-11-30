//
//  LoopMeAdDisplayController.h
//  Tester
//
//  Created by Bohdan on 5/8/17.
//  Copyright © 2017 LoopMe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoopMeVideoCommunicatorProtocol.h"
#import "LoopMeDestinationDisplayController.h"

@protocol LoopMeAdDisplayControllerDelegate;
@class LoopMeAdConfiguration;
@class LoopMeAdWebView;
@class LoopMeDestinationDisplayController;

@interface LoopMeAdDisplayController : NSObject
<
    LoopMeDestinationDisplayControllerDelegate
>

@property (nonatomic, weak) id<LoopMeAdDisplayControllerDelegate> delegate;
@property (nonatomic, strong) id<LoopMeVideoCommunicatorProtocol> videoClient;
@property (nonatomic, weak) LoopMeAdConfiguration *adConfiguration;
@property (nonatomic, strong) LoopMeAdWebView *webView;
@property (nonatomic, strong) LoopMeDestinationDisplayController *destinationDisplayClient;

@property (nonatomic, strong) NSTimer *webViewTimeOutTimer;

@property (nonatomic, assign) BOOL destinationIsPresented;
@property (nonatomic, assign, getter = isVisible) BOOL visible;
@property (nonatomic, assign) BOOL isEndCardClicked;


- (instancetype)initWithDelegate:(id<LoopMeAdDisplayControllerDelegate>)delegate;
- (BOOL)shouldIntercept:(NSURL *)URL
         navigationType:(UIWebViewNavigationType)navigationType;
- (void)setAdConfiguration:(LoopMeAdConfiguration *)configuration;
- (void)loadAdConfiguration;
- (void)displayAd;
- (void)closeAd;
- (void)layoutSubviews;
- (void)layoutSubviewsToFrame:(CGRect)frame;
- (void)stopHandlingRequests;
- (void)cancelWebView;

- (void)expandReporting;
- (void)collapseReporting;

@end


@protocol LoopMeAdDisplayControllerDelegate <NSObject>

- (void)adDisplayControllerDidReceiveTap:(LoopMeAdDisplayController *)adDisplayController;
- (void)adDisplayControllerDidFinishLoadingAd:(LoopMeAdDisplayController *)adDisplayController;
- (void)adDisplayController:(LoopMeAdDisplayController *)adDisplayController didFailToLoadAdWithError:(NSError *)error;
- (void)adDisplayControllerWillLeaveApplication:(LoopMeAdDisplayController *)adDisplayController;
- (void)adDisplayControllerShouldCloseAd:(LoopMeAdDisplayController *)adDisplayController;
- (void)adDisplayControllerVideoDidReachEnd:(LoopMeAdDisplayController *)adDisplayController;
- (void)adDisplayControllerDidDismissModal:(LoopMeAdDisplayController *)adDisplayController;
- (void)adDisplayControllerWillExpandAd:(LoopMeAdDisplayController *)adDisplayController;
- (void)adDisplayControllerWillCollapse:(LoopMeAdDisplayController *)adDisplayController;
- (UIViewController *)viewControllerForPresentation;
- (UIView *)containerView;
- (NSString *)appKey;

@end
