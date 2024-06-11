//
//  LoopMeSDK.m
//  Demo
//
//  Created by Bohdan on 4/17/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

#import "LoopMeSDK.h"
#import "LoopMeGlobalSettings.h"
#import "LoopMeGDPRTools.h"
#import "LoopMeErrorEventSender.h"
#import "LoopMeDefinitions.h"
#import <LoopMeUnitedSDK/LoopMeUnitedSDK-Swift.h>

@class LoopMeOMIDWrapper;

@interface LoopMeSDK ()

@property (nonatomic) BOOL isReady;

@end

@implementation LoopMeSDK

+ (instancetype)shared {
    static LoopMeSDK *instance;
    
    if (!instance) {
        instance = [[LoopMeSDK alloc] init];
    }
    
    return instance;
}

+ (NSString *)version {
    return LOOPME_SDK_VERSION;
}

/// TODO: Remove and use `init` instead of `initSDKFromRootViewController`
- (void)initSDKFromRootViewController: (UIViewController *)rootViewController
                     sdkConfiguration: (LoopMeSDKConfiguration *) configuration
                      completionBlock: (void(^_Nullable)(BOOL, NSError * _Nullable))completionBlock __attribute__((deprecated("Use init:sdkConfiguration:completionBlock instead"))) {
    [self init: configuration completionBlock: completionBlock];
}

/// TODO: Remove and use `init` instead of `initSDKFromRootViewController`
- (void)initSDKFromRootViewController: (UIViewController *)rootViewController
                      completionBlock: (void(^_Nullable)(BOOL, NSError * _Nullable))completionBlock __attribute__((deprecated("Use init:completionBlock instead"))) {
    [self init: completionBlock];
}

- (void)init: (void(^_Nullable)(BOOL, NSError *))completionBlock {
    [self init: [LoopMeSDKConfiguration defaultConfiguration] completionBlock: completionBlock];
}

- (void)init: (LoopMeSDKConfiguration *)configuration completionBlock: (void(^_Nullable)(BOOL, NSError *))completionBlock {
    if (self.isReady) {
        return;
    }
    
    if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey : @"Block iOS versions less then 10.0"};
        if (completionBlock != nil) {
            completionBlock(false, [NSError errorWithDomain: @"loopme.com" code: 0 userInfo: userInfo]);
        }
        return;
    }
    
    [[LoopMeGDPRTools sharedInstance] getAppDetailsFromServer];
    [[LoopMeGDPRTools sharedInstance] prepareConsent];
    [LoopMeGlobalSettings sharedInstance];
    // TODO: Why we do not store OMID Wrapper instance?
    (void)[LoopMeOMIDWrapper initOMIDWithCompletionBlock: ^(BOOL ready) {
        if (self.isReady && ready) {
            return;
        }
        NSArray<NSString *>* info = @[self.isReady ? @"LM_SDK_READY" : @"LM_SDK_NOT_READY", ready ? @"OMSDK_READY" : @"OMSDK_NOT_READY"];
        self.isReady = ready;
        NSError *error;
        NSString *description = @"LoopMe OMID fail to initialize";
        if (!ready) {
            [LoopMeErrorEventSender sendError: LoopMeEventErrorTypeServer
                                 errorMessage: description
                                       appkey: @"unknown"
                                         info: info];
            error = [NSError errorWithDomain: @"loopme.com" code: -1 userInfo: @{NSLocalizedDescriptionKey: description}];
        }
        if (completionBlock != nil) {
            completionBlock(ready, error);
        }
    }];
}

@end
