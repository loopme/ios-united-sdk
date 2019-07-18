//
//  LoopMeSDK.h
//  Demo
//
//  Created by Bohdan on 4/17/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoopMeSDKConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface LoopMeSDK : NSObject

@property (nonatomic, readonly) BOOL isReady;

+ (instancetype)shared;

- (void)initSDKFromRootViewController:(UIViewController *)rootViewController
                     sdkConfiguration:(LoopMeSDKConfiguration *) configuration
                     completionBlock :(void(^_Nullable)(BOOL,  NSError * _Nullable))completionBlock;

- (void)initSDKFromRootViewController:(UIViewController *)rootViewController completionBlock :(void(^_Nullable)(BOOL, NSError * _Nullable))completionBlock;

@end

NS_ASSUME_NONNULL_END
