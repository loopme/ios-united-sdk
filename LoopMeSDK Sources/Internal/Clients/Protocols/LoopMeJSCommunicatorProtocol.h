//
//  LoopMeVideoJSTransportProtocol.h
//  LoopMeSDK
//
//  Created by Dmitriy on 10/28/14.
//
//

#ifndef LoopMeSDK_LoopMeJSCommunicatorProtocol_h
#define LoopMeSDK_LoopMeJSCommunicatorProtocol_h

@protocol LoopMeJSCommunicatorProtocol <NSObject>

- (void)setCurrentTime:(CGFloat)currentTime;
- (void)setDuration:(CGFloat)fullDuration;
- (void)setVideoState:(NSString *)state;
- (void)setFullScreenModeEnabled:(BOOL)enabled;
- (void)setShake;

- (void)track360LeftSector;
- (void)track360FrontSector;
- (void)track360BackSector;
- (void)track360RightSector;
- (void)track360Gyro;
- (void)track360Swipe;
- (void)track360Zoom;
@end

#endif
