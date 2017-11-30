//
//  LoopMeMinimizedView.m
//  LoopMeSDKTester
//
//  Created by Dmitriy on 5/13/15.
//  Copyright (c) 2015 Injectios. All rights reserved.
//

#import "LoopMeMinimizedAdView.h"
#import "LoopMeDefinitions.h"
#import "LoopMeLogging.h"

const float kLoopMeFlyAwayAnimationDuration = .3f;
const float kLoopMeFlyAwayOffset = 50.0f;

const float kLoopMeMinimizedAdPadding = 5.0f;
const float kLoopMeMinimizedAdWidth = 150.0f;
const float kLoopMeMinimizedAdHeight = 90.0f;

@implementation LoopMeMinimizedAdView

#pragma mark - Services

- (instancetype)initWithDelegate:(id<LoopMeMinimizedAdViewDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeLeft:)];
        [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
        [self addGestureRecognizer:swipeLeft];
        
        UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeRight:)];
        [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
        [self addGestureRecognizer:swipeRight];
        
        UITapGestureRecognizer *touch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
        [self addGestureRecognizer:touch];
        
        self.alpha = 0;
        
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.borderWidth = 1.f;
        
        self.layer.shadowColor= [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.3;
        self.layer.shadowRadius = 6.0;
        self.layer.shadowOffset = CGSizeMake(-2, -2);
    }
    return self;
}

#pragma mark - Public

- (BOOL)isAdded {
    return (self.superview) ? YES : NO;
}

- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated {
    float angle = 0;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            angle = M_PI;
        }
    } else {
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            angle = -M_PI_2;
        } else {
            angle = M_PI_2;
        }
    }
    
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        self.transform = CGAffineTransformMakeRotation(angle);
        [UIView commitAnimations];
    } else {
        self.transform = CGAffineTransformMakeRotation(angle);
    }
}

- (void)show {
    [self rotateToInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation animated:NO];
    [self adjustFrame];
    self.alpha = 0;
    [UIView beginAnimations:@"minimizeAnimationShow" context:nil];
    [UIView setAnimationDuration:kLoopMeFlyAwayAnimationDuration];
    self.alpha = 1;
    [UIView commitAnimations];
}

- (void)hide {
    [UIView beginAnimations:@"minimizeAnimationHide" context:nil];
    [UIView setAnimationDuration:kLoopMeFlyAwayAnimationDuration/2];
    self.alpha = 0;
    [UIView commitAnimations];
}

- (void)adjustFrame {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    if (SYSTEM_VERSION_GREATER_THAN(@"8.0")) {
        float minimizedWidth;
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            minimizedWidth = window.frame.size.width/2;
        } else {
            minimizedWidth = window.frame.size.height/2;
        }
        float minimizedHeight = minimizedWidth*2/3;
        
        self.frame = CGRectMake(window.bounds.size.width - minimizedWidth - kLoopMeMinimizedAdPadding,
                          window.bounds.size.height - minimizedHeight - kLoopMeMinimizedAdPadding,
                          minimizedWidth,
                          minimizedHeight);
    } else {
        
        float width = window.frame.size.width;
        float height = window.frame.size.height;
        float minimizedWidth = width/2;
        float minimizedHeight = minimizedWidth*2/3;
        CGPoint origin;
        CGRect minimizedRect;
        
        if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait) {
            origin = CGPointMake(width - minimizedWidth - kLoopMeMinimizedAdPadding,
                                 height - minimizedHeight - kLoopMeMinimizedAdPadding);
            minimizedRect = CGRectMake(origin.x,
                                       origin.y,
                                       minimizedWidth,
                                       minimizedHeight);
            
        } else if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown) {
            origin = CGPointMake(kLoopMeMinimizedAdPadding,
                                 kLoopMeMinimizedAdPadding);
            minimizedRect = CGRectMake(origin.x,
                                       origin.y,
                                       minimizedWidth,
                                       minimizedHeight);
            
        } else if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft) {
            origin = CGPointMake(width - minimizedHeight - kLoopMeMinimizedAdPadding,
                                 kLoopMeMinimizedAdPadding);
            minimizedRect = CGRectMake(origin.x,
                                       origin.y,
                                       minimizedHeight,
                                       minimizedWidth);
            
        } else {
            origin = CGPointMake(kLoopMeMinimizedAdPadding,
                                 height - minimizedWidth - kLoopMeMinimizedAdPadding);
            minimizedRect = CGRectMake(origin.x,
                                       origin.y,
                                       minimizedHeight,
                                       minimizedWidth);
        }
        self.frame = minimizedRect;
    }
}

#pragma mark - Gestures 

- (void)didSwipeLeft:(UISwipeGestureRecognizer *)recognizer {
    [self removeOnDirection:recognizer.direction animated:YES];
}

- (void)didSwipeRight:(UISwipeGestureRecognizer *)recognizer {
    [self removeOnDirection:recognizer.direction animated:YES];
}

- (void)didTap:(UITapGestureRecognizer *)recognizer {
    if ([self.delegate respondsToSelector:@selector(minimizedDidReceiveTap:)]) {
        [self.delegate minimizedDidReceiveTap:self];
    }
}

#pragma mark - Private

- (void)removeOnDirection:(UISwipeGestureRecognizerDirection)direction animated:(BOOL)animated {
    
    CGRect flyAwayRect = [self flyAwayRectForDirection:direction];
    
    [UIView animateWithDuration:kLoopMeFlyAwayAnimationDuration animations:^{
        self.frame = flyAwayRect;
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(minimizedAdViewShouldRemove:)]) {
            [self.delegate minimizedAdViewShouldRemove:self];
        }
    }];
}

- (CGRect)flyAwayRectForDirection:(UISwipeGestureRecognizerDirection)direction {
    CGRect flyAwayRect = self.frame;
    switch (direction) {
        case UISwipeGestureRecognizerDirectionLeft:
            
            if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait) {
                flyAwayRect.origin.x -= kLoopMeFlyAwayOffset;
            } else if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown) {
                    flyAwayRect.origin.x += kLoopMeFlyAwayOffset;
            } else if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft) {
                flyAwayRect.origin.y += kLoopMeFlyAwayOffset;
            } else if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight) {
                flyAwayRect.origin.y -= kLoopMeFlyAwayOffset;
            }
            break;
        case UISwipeGestureRecognizerDirectionRight:
            if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait) {
                flyAwayRect.origin.x += kLoopMeFlyAwayOffset;
            } else if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown) {
                flyAwayRect.origin.x -= kLoopMeFlyAwayOffset;
            } else if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft) {
                flyAwayRect.origin.y -= kLoopMeFlyAwayOffset;
            } else if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight) {
                flyAwayRect.origin.y += kLoopMeFlyAwayOffset;
            }
            
            break;
        default:
            LoopMeLogError(@"Unknown swipe direction for minimized ad %@", self);
            break;
    }
    return flyAwayRect;
}

@end
