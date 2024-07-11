//
//  ISLoopmeCustomInterstitial.h
//  IronSourceDemoApp
//
//  Created by Volodymyr Novikov on 14.12.2021.
//  Copyright © 2021 supersonic. All rights reserved.
//

#ifndef ISLoopmeCustomInterstitial_h
#define ISLoopmeCustomInterstitial_h

#import "IronSource/IronSource.h"
#import "LoopMeUnitedSDK/LoopMeInterstitial.h"

@interface ISLoopmeCustomInterstitial : ISBaseInterstitial<LoopMeInterstitialDelegate>

@property (nonatomic, strong) LoopMeInterstitial *interstitial;
@property (nonatomic, strong) id<ISInterstitialAdDelegate> delegate;

@end

#endif /* ISLoopmeCustomInterstitial_h */
