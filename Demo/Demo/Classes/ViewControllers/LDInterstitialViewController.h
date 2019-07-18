//
//  LDInterstitialViewController.h
//  LoopmeDemo
//
//  Copyright (c) 2015 Loopmemedia. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LDButtonState) {
    LDButtonStateLoad,
    LDButtonStateLoading,
    LDButtonStateShow,
    LDButtonStateRetry
};

typedef NS_ENUM(NSUInteger, LDLoadStyle) {
    LDLoadStyleSeparately,
    LDLoadStyleSame
};


@interface LDInterstitialViewController : UIViewController

@property (nonatomic) NSString *appKey;
@property (assign) LDLoadStyle loadStyle;

@end

