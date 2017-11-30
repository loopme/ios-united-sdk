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

@property (nonatomic, weak) id<LoopMeServerCommunicatorDelegate> delegate;
@property (nonatomic, assign, readonly, getter = isLoading) BOOL loading;
@property (nonatomic, strong) NSString *appKey;

- (instancetype)initWithDelegate:(id<LoopMeServerCommunicatorDelegate>)delegate;
- (void)loadURL:(NSURL *)URL requestBody:(NSData *)body;
- (void)cancel;

@end

@protocol LoopMeServerCommunicatorDelegate <NSObject>

- (void)serverCommunicator:(LoopMeServerCommunicator *)communicator didReceiveAdConfiguration:(LoopMeAdConfiguration *)configuration;
- (void)serverCommunicator:(LoopMeServerCommunicator *)communicator didFailWithError:(NSError *)error;
- (void)serverCommunicatorDidReceiveAd:(LoopMeServerCommunicator *)communicator;

@end
