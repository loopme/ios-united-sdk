//
//  LoopMeVPAIDAdDisplayController.h
//  LoopMeSDK
//
//  Copyright (c) 2016 LoopMe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoopMeAdDisplayController.h"

@class LoopMeAdConfiguration;

@protocol LoopMeAdDisplayControllerDelegate;
@class LoopMeVASTEventTracker;

@interface LoopMeVPAIDAdDisplayController : LoopMeAdDisplayController

@property (nonatomic, strong, readonly) LoopMeVASTEventTracker *vastEventTracker;

- (instancetype)initWithDelegate:(id<LoopMeAdDisplayControllerDelegate>)delegate;
- (void)moveView:(BOOL)hideWebView;
- (void)startAd;

@end
