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
    [[LoopMeSDK shared] init: ^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"%@", error);
        }
    }];
    
    if (![[LoopMeSDK shared] isReady]) {
        [delegate onInitDidFailWithErrorCode: ISAdapterErrorMissingParams errorMessage: @"SDK is not inited"];
    }
   // init success
   [delegate onInitDidSucceed];
}

- (NSString *) networkSDKVersion {
    return [LoopMeSDK version];
}
- (NSString *) adapterVersion {
   return @"0.0.9";
}

@end
