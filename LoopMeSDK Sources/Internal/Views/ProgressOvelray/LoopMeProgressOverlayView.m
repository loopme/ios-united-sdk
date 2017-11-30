//
//  LoopMeProgressOverlayView.m
//  LoopMeSDK
//
//  Copyright (c) 2016 LoopMe. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "LoopMeActivityIndicatorView.h"
#import "LoopMeDefinitions.h"
#import "LoopMeProgressOverlayView.h"
#import "LoopMeCancelView.h"

@interface LoopMeProgressOverlayView ()

@property (nonatomic, weak) id<LoopMeProgressOverlayViewDelegate> delegate;
@property (nonatomic, strong) UIView *cancelView;
@property (nonatomic, strong) LoopMeActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIView *outerContainer;
@property (nonatomic, strong) UIView *innerContainer;

@end

#define kProgressOverlaySide                184.0
#define kProgressOverlayBorderWidth         1.0
#define kProgressOverlayCornerRadius        5.0
#define kProgressOverlayShadowOpacity       0.8
#define kProgressOverlayShadowRadius        8.0
#define kProgressOverlayCloseButtonDelay    2.0

@implementation LoopMeProgressOverlayView

#pragma mark - LifeCycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.alpha = 0.0;
        self.opaque = NO;
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        // Progress indicator container.
        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 26)];
        container.center = self.center;
        container.backgroundColor = [UIColor clearColor];
        CGRect outerFrame = CGRectMake((200-kProgressOverlaySide)/2, 0, kProgressOverlaySide, 26);
        _outerContainer = [[UIView alloc] initWithFrame:outerFrame];
        _outerContainer.alpha = 0.7;
        _outerContainer.backgroundColor = [UIColor whiteColor];
        _outerContainer.opaque = NO;
        _outerContainer.layer.cornerRadius = kProgressOverlayCornerRadius;
        if ([_outerContainer.layer respondsToSelector:@selector(setShadowColor:)]) {
            _outerContainer.layer.shadowColor = [UIColor blackColor].CGColor;
            _outerContainer.layer.shadowOffset = CGSizeMake(0.0f, kProgressOverlayShadowRadius - 2.0f);
            _outerContainer.layer.shadowOpacity = kProgressOverlayShadowOpacity;
            _outerContainer.layer.shadowRadius = kProgressOverlayShadowRadius;
        }
        [container addSubview:_outerContainer];
        container.autoresizingMask = UIViewAutoresizingFlexibleTopMargin |
        UIViewAutoresizingFlexibleLeftMargin |
        UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleBottomMargin;
        [self addSubview:container];
        
        CGFloat innerSide = kProgressOverlaySide - 2 * kProgressOverlayBorderWidth;
        CGRect innerFrame = CGRectMake(0, 0, innerSide, 24);
        _innerContainer = [[UIView alloc] initWithFrame:innerFrame];
        _innerContainer.backgroundColor = [UIColor blackColor];
        _innerContainer.center = CGPointMake(CGRectGetMidX(_outerContainer.bounds),
                                             CGRectGetMidY(_outerContainer.bounds));
        _innerContainer.layer.cornerRadius =
        kProgressOverlayCornerRadius - kProgressOverlayBorderWidth;
        _innerContainer.opaque = NO;
        [_outerContainer addSubview:_innerContainer];
        
        // Cancel button
        CGRect cancelContainerFrame = CGRectMake(168, 0, 24, _outerContainer.frame.size.height);
        _cancelView = [[UIView alloc] initWithFrame:cancelContainerFrame];
        _cancelView.backgroundColor = [UIColor clearColor];
        
        _cancelView.opaque = NO;
        _cancelView.layer.cornerRadius = kProgressOverlayCornerRadius;
        
        if ([_cancelView.layer respondsToSelector:@selector(setShadowColor:)]) {
            _cancelView.layer.shadowColor = [UIColor blackColor].CGColor;
            _cancelView.layer.shadowOffset = CGSizeMake(0.0f, kProgressOverlayShadowRadius - 2.0f);
            _cancelView.layer.shadowOpacity = kProgressOverlayShadowOpacity;
            _cancelView.layer.shadowRadius = kProgressOverlayShadowRadius;
        }
        
        _cancelView.alpha = 0.1f;
        UIView *xView = [[LoopMeCancelView alloc] initWithFrame:CGRectMake(0, 3, 18, 20)];
        [_cancelView addSubview:xView];
        
        UITapGestureRecognizer *cancelRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeButtonPressed)];
        
        [_cancelView addGestureRecognizer:cancelRecognizer];
        _cancelView.userInteractionEnabled = YES;
        
        _activityIndicator = [[LoopMeActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 2, kProgressOverlaySide - 22, 22)];
        [_activityIndicator startAnimating];
        _activityIndicator.dotCount = 12;
        _activityIndicator.duration = 0.2;
        [_outerContainer addSubview:_activityIndicator];
        self.clipsToBounds = NO;
        
        [container addSubview:_cancelView];
        [self registerForDeviceOrientationNotifications];
    }
    return self;
}

- (void)dealloc {
    [self unregisterForDeviceOrientationNotifications];
}

#pragma mark - Public Class Methods

+ (void)presentOverlayInWindow:(UIWindow *)window animated:(BOOL)animated
                      delegate:(id<LoopMeProgressOverlayViewDelegate>)delegate {
    if ([self windowHasExistingOverlay:window]) {
        return;
    }
    
    LoopMeProgressOverlayView *overlay = [[LoopMeProgressOverlayView alloc] initWithFrame:window.bounds];
    overlay.delegate = delegate;
    [overlay setTransformForCurrentOrientationAnimated:NO];
    [window addSubview:overlay];
    [overlay displayUsingAnimation:animated];
}

+ (void)dismissOverlayFromWindow:(UIWindow *)window animated:(BOOL)animated {
    LoopMeProgressOverlayView *overlay = [self overlayForWindow:window];
    [overlay.activityIndicator stopAnimating];
    [overlay hideUsingAnimation:animated];
}

#pragma mark - Internal Class Methods

+ (BOOL)windowHasExistingOverlay:(UIWindow *)window {
    return !![self overlayForWindow:window];
}

+ (LoopMeProgressOverlayView *)overlayForWindow:(UIWindow *)window {
    NSArray *subviews = window.subviews;
    for (UIView *view in subviews) {
        if ([view isKindOfClass:[LoopMeProgressOverlayView class]]) {
            return (LoopMeProgressOverlayView *)view;
        }
    }
    return nil;
}

#pragma mark - Drawing and Layout

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colSp = CGColorSpaceCreateDeviceRGB();
    
    CGGradientRef gradient = CGGradientCreateWithColors(colSp, (__bridge CFArrayRef)[NSArray arrayWithObjects:(id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0] CGColor], (id)[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8] CGColor], nil], 0);
    
    CGContextDrawRadialGradient(context, gradient, self.center, 0, self.center, self.bounds.size.height/2 + self.bounds.size.width/2, 0);
    
    CGColorSpaceRelease(colSp);
    CGGradientRelease(gradient);
}

#pragma mark - Observing

- (void)registerForDeviceOrientationNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)unregisterForDeviceOrientationNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    [self setTransformForCurrentOrientationAnimated:YES];
}

#pragma mark - Private

- (void)displayUsingAnimation:(BOOL)animated {
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        self.alpha = 1.0;
        [UIView commitAnimations];
    } else {
        self.alpha = 1.0;
    }
    
    [self performSelector:@selector(enableCloseButton)
               withObject:nil
               afterDelay:kProgressOverlayCloseButtonDelay];
}

- (void)enableCloseButton {
    self.cancelView.alpha = 0.1;
    [UIView beginAnimations:nil context:nil];
    self.cancelView.alpha = 0.7;
    [UIView commitAnimations];
}

- (void)closeButtonPressed {
    if ([self.delegate respondsToSelector:@selector(overlayCancelButtonPressed:)]) {
        [self.delegate overlayCancelButtonPressed:self];
    }
}

- (void)hideUsingAnimation:(BOOL)animated {
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(hideAnimationDidStop:finished:context:)];
        self.alpha = 0.0;
        [UIView commitAnimations];
    } else {
        self.alpha = 0.0;
        [self removeFromSuperview];
    }
}

- (void)hideAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished
                     context:(void *)context {
    [self removeFromSuperview];
}

- (void)setTransformForCurrentOrientationAnimated:(BOOL)animated {
    if (SYSTEM_VERSION_GREATER_THAN(@"8.0")) {
        return;
    }
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
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
        [self setTransformForAllSubviews:CGAffineTransformMakeRotation(angle)];
        [UIView commitAnimations];
    } else {
        [self setTransformForAllSubviews:CGAffineTransformMakeRotation(angle)];
    }
}

- (void)setTransformForAllSubviews:(CGAffineTransform)transform {
    for (UIView *view in self.subviews) {
        view.transform = transform;
    }
}

@end
