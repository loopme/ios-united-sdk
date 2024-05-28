//
//  LoopMeHTMLInterstitialViewController.m
//  LoopMeSDK
//
//  Created by Dmitriy Lihachov on 8/21/12.
//  Copyright (c) 2012 LoopMe. All rights reserved.
//

#import <LoopMeUnitedSDK/LoopMeUnitedSDK-Swift.h>
#import "LoopMeInterstitialViewController.h"

@interface LoopMeInterstitialViewController ()

@property (nonatomic, assign) LoopMeAdOrientation adOrientation;
@property (nonatomic, assign) BOOL allowOrientationChange;

@end

@implementation LoopMeInterstitialViewController

#pragma mark - Life Cycle

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self.delegate viewWillTransitionToSize:self.view.frame.size];
}

#pragma mark - Private

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark Orientation handling

- (BOOL)shouldAutorotate {
    return self.allowOrientationChange;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if (self.adOrientation == LoopMeAdOrientationLandscape) {
        if (@available(iOS 13.0, *)) {
            if (UIInterfaceOrientationIsLandscape([[[self view] window] windowScene].interfaceOrientation)) {
                return [[[self view] window] windowScene].interfaceOrientation;
            }
        } else {
            if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
                return [UIApplication sharedApplication].statusBarOrientation;
            }
        }
        return UIInterfaceOrientationLandscapeLeft;
    } else {
        return UIInterfaceOrientationPortrait;
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIInterfaceOrientationMask applicationSupportedOrientations =
    [[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:[UIApplication sharedApplication].keyWindow];
    UIInterfaceOrientationMask interstitialSupportedOrientations = applicationSupportedOrientations;
    
    if (self.adOrientation == LoopMeAdOrientationPortrait) {
        interstitialSupportedOrientations |=
        (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown);
    } else if (self.adOrientation == LoopMeAdOrientationLandscape) {
        interstitialSupportedOrientations |= UIInterfaceOrientationMaskLandscape;
    }
    
    return interstitialSupportedOrientations;
}

#pragma mark - Public

- (void)setOrientation:(LoopMeAdOrientation)orientation {
    _adOrientation = orientation;
}

- (void)setAllowOrientationChange:(BOOL)autorotate {
    _allowOrientationChange = autorotate;
}

- (void)forceChangeOrientation {
    UIViewController *presentingVC = self.presentingViewController;
    [self dismissViewControllerAnimated:NO completion:^{
        [presentingVC presentViewController:self animated:NO completion:nil];
    }];
}

#pragma mark Notifications

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DeviceShaken" object:self];
    }
}

#pragma mark - Public

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
        UIView *container = context.containerView;
        CGRect containerFrame = container.frame;
        CGSize authenticSize = containerFrame.size; //use the size from the container view to workaround bogus size.
        
        if ([self.delegate respondsToSelector:@selector(viewWillTransitionToSize:)]) {
            [self.delegate viewWillTransitionToSize:authenticSize];
        }

    } completion:nil];
}

@end
