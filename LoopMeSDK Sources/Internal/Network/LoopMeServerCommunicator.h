//
//  LoopMeServerCommunicator.h
//  LoopMeSDK
//
//  Created by Dmitriy Lihachov on 07/11/13.
//  Copyright (c) 2013 LoopMe. All rights reserved.
//

@class LoopMeServerCommunicator;
@class LoopMeAdConfiguration;

@protocol LoopMeServerCommunicatorDelegate;

@interface LoopMeServerCommunicator : NSObject
<
    NSURLConnectionDataDelegate
>

@property (nonatomic, weak) id<LoopMeServerCommunicatorDelegate> _Nullable delegate;
@property (nonatomic, assign, readonly, getter = isLoading) BOOL loading;
@property (nonatomic, strong) NSString * _Nullable appKey;

- (_Nullable instancetype)initWithDelegate:(id<LoopMeServerCommunicatorDelegate> _Nullable)delegate;
- (void)loadURL:(NSURL * _Nonnull)URL requestBody:(NSData * _Nullable)body method:(NSString * _Nullable) method;
- (void)cancel;

@end

@protocol LoopMeServerCommunicatorDelegate <NSObject>

- (void)serverCommunicator:(LoopMeServerCommunicator * _Nonnull)communicator didReceiveAdConfiguration:(LoopMeAdConfiguration * _Nonnull)configuration;
- (void)serverCommunicator:(LoopMeServerCommunicator * _Nonnull)communicator didFailWithError:(NSError * _Nonnull)error;
- (void)serverCommunicatorDidReceiveAd:(LoopMeServerCommunicator * _Nonnull)communicator;

@end
