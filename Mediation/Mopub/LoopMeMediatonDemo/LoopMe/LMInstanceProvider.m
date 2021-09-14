//
//  MPInstanceProvider+LoopMe.m
//  LoopMeMediatonDemo
//
//  Created by Bohdan on 10/6/17.
//  Copyright © 2017 injectios. All rights reserved.
//

#import "LMInstanceProvider.h"
#import "LoopMeUnitedSDK/LoopMeInterstitial.h"

@implementation LMInstanceProvider

+ (instancetype)sharedProvider {
    static LMInstanceProvider *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LMInstanceProvider alloc] init];
    });
    
    return instance;
}

- (LoopMeInterstitial *)buildLoopMeInterstitialWithAppKey:(NSString *)appKey
                                                 delegate:(id<LoopMeInterstitialDelegate>)delegate {
    LoopMeInterstitial *interstitial = [LoopMeInterstitial interstitialWithAppKey:appKey
                                                                         delegate:delegate];
    return interstitial;
}

@end
