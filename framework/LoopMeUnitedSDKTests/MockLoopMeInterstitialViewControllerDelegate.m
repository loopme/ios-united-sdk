//
//  MockLoopMeInterstitialViewControllerDelegate.m
//  LoopMeUnitedSDKTests
//
//  Created by Valerii Roman on 24/05/2024.
//  Copyright © 2024 LoopMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "LoopMeInterstitialViewController.h"

@interface MockLoopMeInterstitialViewControllerDelegate : NSObject <LoopMeInterstitialViewControllerDelegate>

@property (nonatomic, assign) BOOL viewWillTransitionToSizeCalled;
@property (nonatomic, assign) CGSize lastSize;

@end

@implementation MockLoopMeInterstitialViewControllerDelegate

- (void)viewWillTransitionToSize:(CGSize)size {
    self.viewWillTransitionToSizeCalled = YES;
    self.lastSize = size;
}

@end
