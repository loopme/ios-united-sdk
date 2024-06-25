//
//  LoopMeVPAIDClient.h
//  LoopMeSDK
//
//  Copyright (c) 2016 LoopMe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LoopMeVPAIDClient;
@class WKWebView;
@class LoopMeAdConfiguration;

@protocol LoopMeVpaidProtocol;

extern const struct LoopMeVPAIDViewModeStruct {
    __unsafe_unretained NSString *normal;
    __unsafe_unretained NSString *thumbnail;
    __unsafe_unretained NSString *fullscreen;
} LoopMeVPAIDViewMode;

@interface LoopMeVPAIDClient : NSObject

- (instancetype)initWithDelegate: (id<LoopMeVpaidProtocol>)deleagate webView: (WKWebView *)webView;
- (double)handshakeVersion;
- (void)initAdWithWidth: (int)width
                 height: (int)height
               viewMode: (NSString *)viewMode
         desiredBitrate: (double)desiredBitrate
           creativeData: (NSString *)creativeData;
- (void)resizeAdWithWidth: (int)width
                   height: (int)height
                 viewMode: (NSString *)viewMode;
- (void)startAd;
- (void)stopAd;
- (void)pauseAd;
- (void)resumeAd;
- (void)expandAd;
- (void)collapseAd;
- (void)skipAd;
- (void)setAdVolume: (double)volume;

@end

@protocol LoopMeVpaidProtocol

- (void)processCommand: (NSString *)command withParams: (NSDictionary *)params;

- (void)vpaidAdLoaded: (double)volume;
- (void)vpaidAdSizeChange: (CGSize)size;
- (void)vpaidAdStarted;
- (void)vpaidAdStopped;
- (void)vpaidAdPaused;
- (void)vpaidAdPlaying;
- (void)vpaidAdExpandedChange: (BOOL)expanded;
- (void)vpaidAdSkipped;
- (void)vpaidAdVolumeChanged: (double)volume;
- (void)vpaidAdSkippableStateChange;
- (void)vpaidAdLinearChange;
- (void)vpaidAdDurationChange;
- (void)vpaidAdRemainingTimeChange: (double)time;
- (void)vpaidAdImpression;

- (void)vpaidAdVideoStart;
- (void)vpaidAdVideoFirstQuartile;
- (void)vpaidAdVideoMidpoint;
- (void)vpaidAdVideoThirdQuartile;
- (void)vpaidAdVideoComplete;

- (void)vpaidAdClickThru: (NSString *)url id: (NSString *)Id playerHandles: (BOOL)playerHandles;
- (void)vpaidAdInteraction: (NSString *)eventID;
- (void)vpaidAdUserAcceptInvitation;
- (void)vpaidAdUserMinimize;
- (void)vpaidAdUserClose;

- (void)vpaidAdError: (NSString *)error;
- (void)vpaidAdLog: (NSString *)message;

- (void)vpaidJSError: (NSString *)message;
- (void)vpaidAdVideoSource: (NSString *)videoSource;

- (LoopMeAdConfiguration *)adConfigurationObject;

@end
