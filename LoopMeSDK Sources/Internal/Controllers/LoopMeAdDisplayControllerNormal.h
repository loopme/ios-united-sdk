//
//  LoopMeAdDisplayController.h
//  LoopMeSDK
//
//  Created by Dmitriy Lihachov on 8/21/12.
//  Copyright (c) 2013 LoopMe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoopMeAdDisplayController.h"

@class LoopMeJSClient;
@class LoopMeAdConfiguration;
@class LoopMeAdWebView;
@class LoopMeDestinationDisplayController;

@protocol LoopMeAdDisplayControllerDelegate;

@interface LoopMeAdDisplayControllerNormal : LoopMeAdDisplayController

@property (nonatomic, assign, getter=isVisibleNoJS) BOOL visibleNoJS;
@property (nonatomic, assign) BOOL forceHidden;
@property (nonatomic, assign) BOOL isInterstitial;


- (instancetype)initWithDelegate:(id<LoopMeAdDisplayControllerDelegate>)delegate;

- (void)displayAd;
- (void)closeAd;
- (void)moveView:(BOOL)hideWebView;

- (void)expandReporting;
- (void)collapseReporting;

- (void)resizeTo:(CGSize)size;
- (void)setExpandProperties:(LoopMeAdConfiguration *)configuration;

@end
