//
//  LoopMeMaximizedViewController.m
//  LoopMeSDK
//
//  Created by Kogda Bogdan on 9/7/15.
//  Copyright (c) 2015 LoopMe. All rights reserved.
//

#import "LoopMeMaximizedViewController.h"
#import "LoopMeAdDisplayControllerNormal.h"
#import "LoopMeAdConfiguration.h"

@interface LoopMeMaximizedViewController ()

@property (nonatomic, weak) id<LoopMeMaximizedViewControllerDelegate, LoopMeAdDisplayControllerDelegate> delegate;
@property (nonatomic, assign) LoopMeAdOrientation adOrientation;
@property (nonatomic, assign) BOOL allowOrientationChange;

@end

@implementation LoopMeMaximizedViewController

- (instancetype)initWithDelegate:(id<LoopMeMaximizedViewControllerDelegate, LoopMeAdDisplayControllerDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _allowOrientationChange = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didPinch:)];
    [self.view addGestureRecognizer:pinch];
    
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
    return self.allowOrientationChange;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if (self.adOrientation == LoopMeAdOrientationLandscape) {
        if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            return [UIApplication sharedApplication].statusBarOrientation;
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

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self.delegate maximizedControllerWillTransitionToSize:size];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark -- Public methods

- (void)show {
    [[self.delegate viewControllerForPresentation] presentViewController:self animated:NO completion:^{
        [self.delegate maximizedAdViewDidPresent:self];
    }];
}

- (void)hide {
    [self dismissViewControllerAnimated:NO completion:^{
        [self.delegate maximizedViewControllerShouldRemove:self];
    }];
}

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

#pragma mark - Gestures

- (void)didPinch:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.scale < 1) {
        [self dismissViewControllerAnimated:NO completion:^{
            [self.delegate maximizedViewControllerShouldRemove:self];
        }];
    }
}

@end
