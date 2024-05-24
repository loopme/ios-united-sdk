//
//  LoopMeInterstitialViewControllerTests.m
//  LoopMeUnitedSDKTests
//
//  Created by Valerii Roman on 24/05/2024.
//  Copyright © 2024 LoopMe. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LoopMeInterstitialViewController.h"
#import "MockLoopMeInterstitialViewControllerDelegate.h"

@interface LoopMeInterstitialViewControllerTests : XCTestCase

@property (nonatomic, strong) LoopMeInterstitialViewController *viewController;
@property (nonatomic, strong) MockLoopMeInterstitialViewControllerDelegate *mockDelegate;

@end

@implementation LoopMeInterstitialViewControllerTests

- (void)setUp {
    [super setUp];
    self.viewController = [[LoopMeInterstitialViewController alloc] init];
    self.mockDelegate = [[MockLoopMeInterstitialViewControllerDelegate alloc] init];
    self.viewController.delegate = self.mockDelegate;
}

- (void)tearDown {
    self.viewController = nil;
    self.mockDelegate = nil;
    [super tearDown];
}

- (void)testViewWillTransitionToSize {
    CGSize testSize = CGSizeMake(320, 480);
    
    // Simulate viewDidLayoutSubviews call
    [self.viewController viewDidLayoutSubviews];
    
    // Verify that the delegate method was called
    XCTAssertTrue(self.mockDelegate.viewWillTransitionToSizeCalled, @"The viewWillTransitionToSize delegate method should be called");
    XCTAssertEqual(self.mockDelegate.lastSize, self.viewController.view.frame.size, @"The size passed to the delegate should match the view's frame size");
}

@end
