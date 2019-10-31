//
//  LoopMeJSVideoTransporProtocol.h
//  LoopMeSDK
//
//  Created by Dmitriy on 10/28/14.
//
//

#ifndef LoopMeSDK_LoopMeVideoCommunicatorProtocol_h
#define LoopMeSDK_LoopMeVideoCommunicatorProtocol_h

@protocol LoopMeVideoCommunicatorProtocol <NSObject>

- (BOOL)playerReachedEnd;
- (void)cancel;

- (void)adjustViewToFrame:(CGRect)frame;
- (void)loadWithURL:(NSURL *)URL;
- (void)playFromTime:(double)time;
- (void)setMute:(BOOL)mute;
- (void)setGravity:(NSString *)gravity;

- (void)play;
- (void)resume;
- (void)pause;

@optional
- (void)pauseOnTime:(double)time;

@end

#endif
