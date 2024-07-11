//
//  ISLoopmeCustomBanner.h
//  IronSourceDemoApp
//
//  Created by ValeriiRoman on 29/09/2023.
//  Copyright © 2023 supersonic. All rights reserved.
//

#ifndef ISLoopmeCustomBanner_h
#define ISLoopmeCustomBanner_h

#import <IronSource/IronSource.h>
#import "LoopMeUnitedSDK/LoopMeAdView.h"

@interface ISLoopmeCustomBanner : ISBaseBanner<LoopMeAdViewDelegate>

@property (nonatomic, strong) LoopMeAdView *banner;
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, strong) id<ISBannerAdDelegate> delegate;

@end

#endif /* ISLoopmeCustomBanner_h */
