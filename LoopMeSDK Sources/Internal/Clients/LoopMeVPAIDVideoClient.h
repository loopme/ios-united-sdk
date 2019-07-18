//
//  LoopMeVPAIDVideoClient.h
//  LoopMeSDK
//
//  Copyright (c) 2016 LoopMe. All rights reserved.
//

#import "LoopMeVASTPlayerUIView.h"
#import "LoopMeSkipOffset.h"
#import "LoopMeVideoCommunicatorProtocol.h"

@class LoopMeVPAIDVideoClient;
@class LoopMeVASTEventTracker;
@class AVPlayerLayer;
@class LoopMeAdConfiguration;

@protocol LoopMeVPAIDVideoClientDelegate;

@interface LoopMeVPAIDVideoClient : NSObject <LoopMeVideoCommunicatorProtocol>

@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, weak) LoopMeVASTEventTracker *eventSender;
@property (nonatomic, weak) LoopMeAdConfiguration *configuration;
@property (nonatomic, readonly, strong) LoopMeVASTPlayerUIView *vastUIView;
@property (nonatomic, readonly, strong) UIView *videoView;

- (instancetype)initWithDelegate:(id<LoopMeVPAIDVideoClientDelegate>)delegate;
- (void)cancel;
- (void)willAppear;
- (void)moveView;

@end

@protocol LoopMeVPAIDVideoClientDelegate <NSObject>

- (void)videoClientDidBecomeActive:(LoopMeVPAIDVideoClient *)client;
- (void)videoClient:(LoopMeVPAIDVideoClient *)client setupView:(UIView *)view;
- (void)videoClientDidReachEnd:(LoopMeVPAIDVideoClient *)client;
- (void)videoClientDidLoadVideo:(LoopMeVPAIDVideoClient *)client;
- (void)videoClient:(LoopMeVPAIDVideoClient *)client didFailToLoadVideoWithError:(NSError *)error;
- (void)videoClientShouldCloseAd:(LoopMeVPAIDVideoClient *)client;
- (void)videoClientDidExpandTap:(BOOL)expand;
- (void)videoClientDidEndCardTap;
- (void)videoClientDidVideoTap;
- (LoopMeSkipOffset)skipOffset;
- (void)currentTime:(NSTimeInterval) currentTime percent:(double)percent;
@optional
- (LoopMeAdConfiguration *)adConfiguration;

@end
