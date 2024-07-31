//
//  LetancyViewControllerChecker.h
//  IronSourceDemoApp
//
//  Created by Valerii Roman on 17/07/2024.
//
#import <UIKit/UIKit.h>
#import <IronSource/IronSource.h>

#ifndef LetancyViewControllerChecker_h
#define LetancyViewControllerChecker_h


#endif /* LetancyViewControllerChecker_h */

@interface LetancyViewControllerChecker : UIViewController<LevelPlayRewardedVideoManualDelegate ,LevelPlayInterstitialDelegate, LevelPlayBannerDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end
