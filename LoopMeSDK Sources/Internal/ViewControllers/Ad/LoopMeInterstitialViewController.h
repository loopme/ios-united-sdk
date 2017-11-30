//
//  LoopMeHTMLInterstitialViewController.h
//  LoopMeSDK
//
//  Created by Dmitriy Lihachov on 8/21/12.
//  Copyright (c) 2012 LoopMe. All rights reserved.
//

@class LoopMeInterstitialViewController;
@protocol LoopMeInterstitialViewControllerDelegate;

@interface LoopMeInterstitialViewController : UIViewController

@property (nonatomic, weak) id<LoopMeInterstitialViewControllerDelegate> delegate;
- (void)setOrientation:(LoopMeAdOrientation)orientation;
- (void)setAllowOrientationChange:(BOOL)autorotate;
- (void)forceChangeOrientation;

@end

@protocol LoopMeInterstitialViewControllerDelegate <NSObject>

- (void)viewWillTransitionToSize:(CGSize)size;

@end
