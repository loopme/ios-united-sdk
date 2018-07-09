//
//  LoopMeGDPRViewController.h
//  LoopMeSDK
//
//  Created by Bohdan on 5/14/18.
//  Copyright © 2018 LoopMe. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoopMeGDPRViewControllerDelegate;

@interface LoopMeGDPRViewController : UIViewController

@property (nonatomic, weak) id<LoopMeGDPRViewControllerDelegate> delegate;

- (instancetype)initWithURL:(NSURL *)url;

@end

@protocol LoopMeGDPRViewControllerDelegate<NSObject>

- (void)loopMeGDPRViewControllerDidDisapper;

@end
