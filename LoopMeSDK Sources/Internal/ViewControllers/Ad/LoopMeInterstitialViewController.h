//
//  LoopMeHTMLInterstitialViewController.h
//  LoopMeSDK
//
//  Created by Dmitriy Lihachov on 8/21/12.
//  Copyright (c) 2012 LoopMe. All rights reserved.
//

#import "LoopMeOrientationViewControllerProtocol.h"

@class LoopMeInterstitialViewController;
@protocol LoopMeInterstitialViewControllerDelegate;

@interface LoopMeInterstitialViewController : UIViewController <LoopMeOrientationViewControllerProtocol>

@property (nonatomic, weak) id<LoopMeInterstitialViewControllerDelegate> delegate;

@end

@protocol LoopMeInterstitialViewControllerDelegate <NSObject>

- (void)viewWillTransitionToSize:(CGSize)size;

@end
