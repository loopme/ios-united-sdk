//
//  LoopMeMaximizedViewController.m
//  LoopMe
//
//  Created by Kogda Bogdan on 9/7/15.
//  Copyright (c) 2015 LoopMe. All rights reserved.
//

#import "LoopMeMaximizedViewController.h"
#import "LoopMeAdDisplayControllerNormal.h"

@interface LoopMeMaximizedViewController ()

@property (nonatomic, weak) id<LoopMeMaximizedViewControllerDelegate, LoopMeAdDisplayControllerDelegate> delegate;

@end

@implementation LoopMeMaximizedViewController

- (instancetype)initWithDelegate:(id<LoopMeMaximizedViewControllerDelegate, LoopMeAdDisplayControllerDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
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

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    UIInterfaceOrientationMask supportedOrientations = [[UIApplication sharedApplication] supportedInterfaceOrientationsForWindow:[UIApplication sharedApplication].keyWindow];
    if (supportedOrientations & UIInterfaceOrientationMaskLandscape) {
        return UIInterfaceOrientationMaskLandscape;
    }
    return [self.presentingViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft;
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

#pragma mark - Gestures

- (void)didPinch:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.scale < 1) {
        [self dismissViewControllerAnimated:NO completion:^{
            [self.delegate maximizedViewControllerShouldRemove:self];
        }];
    }
}

@end
