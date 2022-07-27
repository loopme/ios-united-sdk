//
//  ApplovinInter.m
//  Applovin-mediation-sample
//
//  Created by Volodymyr Novikov on 22.06.2022.
//

#import <Foundation/Foundation.h>
#import "ApplovinInter.h"
#import <AppLovinSDK/ALSdk.h>
#import <LoopMeUnitedSDK/LoopMeUnitedSDK-Swift.h>

@implementation ApplovinInter

+(void) loadAd:(UIViewController *) controller{
    [[ALSdk shared] initializeSdkWithCompletionHandler:^(ALSdkConfiguration *configuration) {
        
    }];
}

@end
