//
//  MPInstanceProvider+LoopMe.h
//  LoopMeMediatonDemo
//
//  Created by Bohdan on 10/6/17.
//  Copyright © 2017 injectios. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LoopMeInterstitial;
@protocol LoopMeInterstitialDelegate;

@interface LMInstanceProvider : NSObject

+ (instancetype)sharedProvider;

- (LoopMeInterstitial *)buildLoopMeInterstitialWithAppKey:(NSString *)appKey
                                                 delegate:(id<LoopMeInterstitialDelegate>)delegate;
@end
