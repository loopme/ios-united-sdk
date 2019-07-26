//
//  LoopMeAdapterConfiguration.m
//  LoopMeMediatonDemo
//
//  Created by Bohdan on 7/16/19.
//  Copyright © 2019 injectios. All rights reserved.
//

#import "LoopMeAdapterConfiguration.h"
#import "LoopMeDefinitions.h"
#import "LoopMeSDK.h"


@implementation LoopMeAdapterConfiguration

- (NSString *)adapterVersion {
    return [NSString stringWithFormat:@"%@.%@", LOOPME_SDK_VERSION, @"1"];
}

- (NSString *)biddingToken {
    return nil;
}

- (NSString *)moPubNetworkName {
    return @"loopme";
}

- (NSString *)networkSdkVersion {
    return LOOPME_SDK_VERSION;
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> *)configuration complete:(void(^)(NSError *))complete {
    
    [[LoopMeSDK shared] initSDKFromRootViewController:[UIViewController new] completionBlock:^(BOOL success, NSError *error) {
            complete(error);
    }];
}

+ (void)updateInitializationParameters:(NSDictionary *)parameters {
    
}

@end
