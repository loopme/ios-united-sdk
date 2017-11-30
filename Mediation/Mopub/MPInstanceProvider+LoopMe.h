//
//  MPInstanceProvider+LoopMe.h
//  LoopMeMediatonDemo
//
//  Created by Bohdan on 10/6/17.
//  Copyright © 2017 injectios. All rights reserved.
//

#import "MPInstanceProvider.h"

@class LoopMeInterstitial;
@protocol LoopMeInterstitialDelegate;

@interface MPInstanceProvider (LoopMe)
- (LoopMeInterstitial *)buildLoopMeInterstitialWithAppKey:(NSString *)appKey
                                                 delegate:(id<LoopMeInterstitialDelegate>)delegate;
@end
