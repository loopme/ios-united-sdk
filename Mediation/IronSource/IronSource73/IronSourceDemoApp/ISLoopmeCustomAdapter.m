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
    if (![[LoopMeSDK shared] isReady]) {
        [delegate onInitDidFailWithErrorCode:ISAdapterErrorMissingParams errorMessage:@"SDK is not inited"];
    }
   // init success
   [delegate onInitDidSucceed];
}

- (NSString *) networkSDKVersion {
   return @"7.1.0";
}
- (NSString *) adapterVersion {
   return @"1.0.0";
}

@end
