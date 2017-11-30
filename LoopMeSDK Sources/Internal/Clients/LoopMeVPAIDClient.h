//
//  LoopMeVPAIDClient.h
//  LoopMeSDK
//
//  Copyright (c) 2016 LoopMe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoopMeVPAIDClient;
@class JSContext;

@protocol LoopMeVpaidProtocol;

extern const struct LoopMeVPAIDViewModeStruct {
    __unsafe_unretained NSString *normal;
    __unsafe_unretained NSString *thumbnail;
    __unsafe_unretained NSString *fullscreen;

} LoopMeVPAIDViewMode;

@interface LoopMeVPAIDClient : NSObject

- (instancetype)initWithDelegate:(id<LoopMeVpaidProtocol>)deleagate jsContext:(JSContext *)context;

- (double)handshakeVersion;
- (void)initAdWithWidth:(int)width height:(int)height viewMode:(NSString *)viewMode desiredBitrate:(double)desiredBitrate creativeData:(NSDictionary *)creativeData environmentVars:(NSDictionary *)environmentVars;
- (void)resizeAdWithWidth:(int)width height:(int)height viewMode:(NSString *)viewMode;
- (void)startAd;
- (void)stopAd;
- (void)pauseAd;
- (void)resumeAd;
- (void)expandAd;
- (void)collapseAd;
- (void)skipAd;
- (BOOL)getAdExpanded;
- (BOOL)getAdSkippableState;
- (BOOL)getAdLinear;
- (NSInteger)getAdWidth;
- (NSInteger)getAdHeight;
- (NSInteger)getAdRemainingTime;
- (NSInteger)getAdDuration;
- (double)getAdVolume;
- (void)setAdVolume:(double)volume;
- (NSString *)getAdCompanions;
- (BOOL)getAdIcons;
- (void)stopActionTimeOutTimer;

@end

@protocol LoopMeVpaidProtocol <JSExport>

- (void)vpaidAdLoaded;
- (void)vpaidAdSizeChange;
- (void)vpaidAdStarted;
- (void)vpaidAdStopped;
- (void)vpaidAdPaused;
- (void)vpaidAdPlaying;
- (void)vpaidAdExpandedChange;
- (void)vpaidAdSkipped;
- (void)vpaidAdVolumeChanged;
- (void)vpaidAdSkippableStateChange;
- (void)vpaidAdLinearChange;
- (void)vpaidAdDurationChange;
- (void)vpaidAdRemainingTimeChange;
- (void)vpaidAdImpression;

- (void)vpaidAdVideoStart;
- (void)vpaidAdVideoFirstQuartile;
- (void)vpaidAdVideoMidpoint;
- (void)vpaidAdVideoThirdQuartile;
- (void)vpaidAdVideoComplete;

- (void)vpaidAdClickThru:(NSString *)url id:(NSString *)Id playerHandles:(BOOL)playerHandles;
- (void)vpaidAdInteraction:(NSString *)eventID;
- (void)vpaidAdUserAcceptInvitation;
- (void)vpaidAdUserMinimize;
- (void)vpaidAdUserClose;

- (void)vpaidAdError:(NSString *)error;
- (void)vpaidAdLog:(NSString *)message;

- (void)vpaidJSError:(NSString *)message;
- (void)vpaidAdVideoSource:(NSString *)videoSource;

- (NSString *)appKey;

@end
