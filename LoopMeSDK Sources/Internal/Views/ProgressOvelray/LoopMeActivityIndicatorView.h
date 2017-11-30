//
//  LoopMeProgressOverlayView.m
//  LoopMeSDK
//
//  Copyright (c) 2013 LoopMe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoopMeActivityIndicatorView : UIView

@property (nonatomic, assign, getter = isHidesWhenStopped) BOOL hidesWhenStopped;
@property (nonatomic, assign) NSInteger dotCount;
@property (nonatomic, assign) CGFloat duration;

- (void)startAnimating;
- (void)stopAnimating;

@end
