//
//  LoopMeProgressOverlayView.h
//  LoopMeSDK
//
//  Copyright (c) 2013 LoopMe. All rights reserved.
//

@protocol LoopMeProgressOverlayViewDelegate;

@interface LoopMeProgressOverlayView : UIView

+ (void)presentOverlayInWindow:(UIWindow *)window animated:(BOOL)animated
                      delegate:(id<LoopMeProgressOverlayViewDelegate>)delegate;
+ (void)dismissOverlayFromWindow:(UIWindow *)window animated:(BOOL)animated;

@end

@protocol LoopMeProgressOverlayViewDelegate <NSObject>

@optional
- (void)overlayCancelButtonPressed:(LoopMeProgressOverlayView *)overlay;

@end