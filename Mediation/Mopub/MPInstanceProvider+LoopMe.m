//
//  MPInstanceProvider+LoopMe.m
//  LoopMeMediatonDemo
//
//  Created by Bohdan on 10/6/17.
//  Copyright © 2017 injectios. All rights reserved.
//

#import "MPInstanceProvider+LoopMe.h"
#import "LoopMeInterstitial.h"

@implementation MPInstanceProvider (LoopMe)

- (LoopMeInterstitial *)buildLoopMeInterstitialWithAppKey:(NSString *)appKey
                                                 delegate:(id<LoopMeInterstitialDelegate>)delegate {
    LoopMeInterstitial *interstitial = [LoopMeInterstitial interstitialWithAppKey:appKey
                                                                         delegate:delegate];
    return interstitial;
}

@end
