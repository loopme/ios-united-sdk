//
//  LoopMeMaximizedViewController.h
//  LoopMe
//
//  Created by Kogda Bogdan on 9/7/15.
//  Copyright (c) 2015 LoopMe. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoopMeMaximizedViewControllerDelegate;
@protocol LoopMeAdDisplayControllerDelegate;

@interface LoopMeMaximizedViewController : UIViewController

- (instancetype)initWithDelegate:(id<LoopMeMaximizedViewControllerDelegate, LoopMeAdDisplayControllerDelegate>)delegate;
- (void)show;
- (void)hide;

@end

@protocol LoopMeMaximizedViewControllerDelegate <NSObject>

- (void)maximizedViewControllerShouldRemove:(LoopMeMaximizedViewController *)maximizedViewController;
- (void)maximizedAdViewDidPresent:(LoopMeMaximizedViewController *)maximizedViewController;

@end