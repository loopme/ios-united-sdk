//
//  ISLoopmeCustomRewardedVideo.h
//  IronSourceDemoApp
//
//  Created by Volodymyr Novikov on 05.01.2023.
//  Copyright © 2023 supersonic. All rights reserved.
//

#ifndef ISLoopmeCustomRewardedVideo_h
#define ISLoopmeCustomRewardedVideo_h

#import "IronSource/IronSource.h"
#import "LoopMeUnitedSDK/LoopMeInterstitial.h"

@interface ISLoopmeCustomRewardedVideo : ISBaseRewardedVideo<LoopMeInterstitialDelegate>

@property (nonatomic, strong) LoopMeInterstitial *interstitial;
@property (nonatomic, strong) id<ISRewardedVideoAdDelegate> delegate;
@property (nonatomic, assign) BOOL hasRewarded;

@end

#endif /* ISLoopmeCustomRewardedVideo_h */
