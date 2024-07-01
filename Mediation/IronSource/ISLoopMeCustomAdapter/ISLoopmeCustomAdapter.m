//
//  ISLoopmeCustomAdapter.m
//  IronSourceDemoApp
//
//  Created by Volodymyr Novikov on 14.12.2021.
//  Copyright © 2021 supersonic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ISLoopmeCustomAdapter.h"
#import "LoopMeUnitedSDK/LoopMeSDK.h"

@implementation ISLoopmeCustomAdapter

-(void)init:(ISAdData *)adData delegate:(id<ISNetworkInitializationDelegate>)delegate {
    /// https://developers.is.com/ironsource-mobile/ios/custom-adapter-integration-ios/#step-2
    /// ironSource mediation will call the init method of the base adapter as part of any initialization process in the mediation.
    /// As a result, this method can be called several times.
    /// As part of your init implementation, make sure to call the initialization callbacks defined in the NetworkInitializationListener each time;
    /// upon success (onInitSuccess) and/or upon failure (onInitFailed).
    if ([[LoopMeSDK shared] isReady]) {
        if ([delegate respondsToSelector: @selector(onInitDidSucceed)]) {
            [delegate onInitDidSucceed];
        }
        return;
    }
    [[LoopMeSDK shared] init: ^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"Failed to init LoopMeUnitedSDK: %@", error);
            if ([delegate respondsToSelector: @selector(onInitDidFailWithErrorCode:errorMessage:)]) {
                [delegate onInitDidFailWithErrorCode: error.code errorMessage: error.localizedDescription];
            }
        } else {
            
            [[LoopMeSDK shared] setAdapterName: @"ironsource"];
            
            NSLog(@"LoopMeUnitedSDK inited successfully");
            if ([delegate respondsToSelector: @selector(onInitDidSucceed)]) {
                [delegate onInitDidSucceed];
            }
        }
    }];
}

- (NSString *) networkSDKVersion {
    return [LoopMeSDK version];
}
- (NSString *) adapterVersion {
   return @"0.0.11";
}

@end
