//
//  LoopMeMinimizedView.h
//  LoopMeSDKTester
//
//  Created by Dmitriy on 5/13/15.
//  Copyright (c) 2015 Injectios. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LoopMeMinimizedAdView;

@protocol LoopMeMinimizedAdViewDelegate <NSObject>

- (void)minimizedAdViewShouldRemove:(LoopMeMinimizedAdView *)minimizedAdView;
- (void)minimizedDidReceiveTap:(LoopMeMinimizedAdView *)minimizedAdView;

@end

@interface LoopMeMinimizedAdView : UIView

@property (nonatomic, weak) id<LoopMeMinimizedAdViewDelegate> delegate;

- (instancetype)initWithDelegate:(id<LoopMeMinimizedAdViewDelegate>)delegate;
- (BOOL)isAdded;
- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated;
- (void)adjustFrame;
- (void)show;
- (void)hide;

@end
