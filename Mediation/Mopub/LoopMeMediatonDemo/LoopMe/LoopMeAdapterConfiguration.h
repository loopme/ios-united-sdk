//
//  LoopMeAdapterConfiguration.h
//  LoopMeMediatonDemo
//
//  Created by Bohdan on 7/16/19.
//  Copyright © 2019 injectios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MoPub.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoopMeAdapterConfiguration : MPBaseAdapterConfiguration

@property (nonatomic, copy, readonly) NSString * adapterVersion;
@property (nonatomic, copy, readonly) NSString * biddingToken;
@property (nonatomic, copy, readonly) NSString * moPubNetworkName;
@property (nonatomic, copy, readonly) NSString * networkSdkVersion;

+ (void)updateInitializationParameters:(NSDictionary *)parameters;

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *, id> * _Nullable)configuration complete:(void(^ _Nullable)(NSError * _Nullable))complete;

@end

NS_ASSUME_NONNULL_END
