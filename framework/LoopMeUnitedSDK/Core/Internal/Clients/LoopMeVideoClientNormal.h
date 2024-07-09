//
//  LoopMeVideoClient.h
//  LoopMeSDK
//
//  Created by Kogda Bogdan on 10/20/14.
//
//

#import "LoopMeVideoCommunicatorProtocol.h"

@class LoopMeVideoClient;
@class LoopMeAdConfiguration;
@class AVPlayerLayer;

@protocol LoopMeJSCommunicatorProtocol;
@protocol LoopMeVideoClientDelegate;

extern const struct LoopMeVideoStateStruct {
    __unsafe_unretained NSString *ready;
    __unsafe_unretained NSString *completed;
    __unsafe_unretained NSString *playing;
    __unsafe_unretained NSString *paused;
    __unsafe_unretained NSString *broken;
} LoopMeVideoState;

@interface LoopMeVideoClientNormal : NSObject
<
    LoopMeVideoCommunicatorProtocol
>
@property (nonatomic, weak) UIViewController *viewController;

- (instancetype)initWithDelegate:(id<LoopMeVideoClientDelegate>)delegate;
- (void)playVideo:(NSURL *)URL;
- (void)cancel;
- (void)willAppear;
- (void)moveView;

@end

@protocol LoopMeVideoClientDelegate <NSObject>

- (id<LoopMeJSCommunicatorProtocol>)JSCommunicator;
- (void)videoClient:(LoopMeVideoClientNormal *)client setupView:(UIView *)view;
- (void)videoClientDidReachEnd:(LoopMeVideoClientNormal *)client;
- (void)videoClient:(LoopMeVideoClientNormal *)client didFailToLoadVideoWithError:(NSError *)error;
- (void)videoClientDidBecomeActive:(LoopMeVideoClientNormal *)client;
- (UIViewController *)viewControllerForPresentation;
@optional
- (LoopMeAdConfiguration *)adConfiguration;

@end
