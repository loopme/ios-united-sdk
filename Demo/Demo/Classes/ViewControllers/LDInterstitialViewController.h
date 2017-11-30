//
//  LDInterstitialViewController.h
//  LoopmeDemo
//
//  Copyright (c) 2015 Loopmemedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LDInterstitialViewController : UIViewController

@end

typedef NS_ENUM(NSUInteger, LDButtonState) {
    LDButtonStateLoad,
    LDButtonStateLoading,
    LDButtonStateShow,
    LDButtonStateRetry
};