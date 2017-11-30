//
//  LoopMeDVSDKWrapper.m
//  Tester
//
//  Created by Bohdan on 12/15/16.
//  Copyright © 2016 LoopMe. All rights reserved.
//

#import "LoopMeDVSDKWrapper.h"

typedef enum : NSUInteger {
    LoopMeDVSDKEventTypeAdLoaded,
    LoopMeDVSDKEventTypeAdStarted,
    LoopMeDVSDKEventTypeAdStopped,
    LoopMeDVSDKEventTypeAdImpression,
    LoopMeDVSDKEventTypeAdLinearChange,
    LoopMeDVSDKEventTypeAdPaused,
    LoopMeDVSDKEventTypeAdPlaying,
    LoopMeDVSDKEventTypeAdFirstQuartile,
    LoopMeDVSDKEventTypeAdMidpoint,
    LoopMeDVSDKEventTypeAdThirdQuartile,
    LoopMeDVSDKEventTypeAdComplete,
    LoopMeDVSDKEventTypeAdVolumeChange,
    LoopMeDVSDKEventTypeAdDurationChange,
    LoopMeDVSDKEventTypeAdResumedForView,
    LoopMeDVSDKEventTypeAdMute
} LoopMeDVSDKEventType;

@interface LoopMeDVSDKWrapper ()

@property (nonatomic, strong) NSMutableSet *sentEvents;

@end

@implementation LoopMeDVSDKWrapper

+ (LoopMeDVSDKWrapper *)sharedInstance {
    static LoopMeDVSDKWrapper *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LoopMeDVSDKWrapper alloc] init];
        instance.sentEvents = [[NSMutableSet alloc] init];
    });
    return instance;
}

- (void)initWithAPIKey:(NSString *)apiKey {
    [[DVSDK sharedInstance] initWithAPIKey:apiKey];
}

- (void)initWithAPIKey:(NSString *)apiKey delegate:(id<DVSDKInitDelegate>)delegate {
    [[DVSDK sharedInstance] initWithAPIKey:apiKey delegate:delegate];
}

+ (float)getVersion {
    return [DVSDK getVersion];
}

- (void)stopTracking {
    [[DVSDK sharedInstance] stopTracking];
}

- (void)resumeTracking {
    [[DVSDK sharedInstance] resumeTracking];
}

- (void)startMeasuringAd:(UIView *)adView {
    [[DVSDK sharedInstance] startMeasuringAd:adView];
}

- (void)stopMeasuringAd:(UIView *)adView {
    [[DVSDK sharedInstance] stopMeasuringAd:adView];
}

- (void)adLoadedView:(UIView *)playerView withCallback:(id<DVVideoSDKDelegate>)callback
            vastFile:(NSString *)vastFileContent adId:(NSString *)adId {

    if (![self.sentEvents containsObject:@{ adId : @(LoopMeDVSDKEventTypeAdLoaded)}]) {
        [[DVSDK sharedInstance] adLoadedView:playerView withCallback:callback vastFile:vastFileContent adId:adId];
        [self.sentEvents addObject:@{ adId : @(LoopMeDVSDKEventTypeAdLoaded)}];
    }
}

- (void)adStartedForView:(UIView *)playerView adId:(NSString *)adId {
    if (![self.sentEvents containsObject:@{ adId : @(LoopMeDVSDKEventTypeAdStarted)}]) {
        [[DVSDK sharedInstance] adStartedForView:playerView adId:adId];
        [self.sentEvents addObject:@{ adId : @(LoopMeDVSDKEventTypeAdStarted)}];
    }
}

- (void)adStopped:(NSString *)adId {
    if (![self.sentEvents containsObject:@{ adId : @(LoopMeDVSDKEventTypeAdStopped)}]) {
        [[DVSDK sharedInstance] adStopped:adId];
        [self.sentEvents addObject:@{ adId : @(LoopMeDVSDKEventTypeAdStopped)}];
    }
}

- (void)adImpression:(NSString *)adId {
    if (![self.sentEvents containsObject:@{adId : @(LoopMeDVSDKEventTypeAdImpression)}]) {
        [[DVSDK sharedInstance] adImpression:adId];
        [self.sentEvents addObject:@{ adId : @(LoopMeDVSDKEventTypeAdImpression)}];
    }
}

- (void)adLinearChange:(NSString *)adId {
    if (![self.sentEvents containsObject:@{ adId : @(LoopMeDVSDKEventTypeAdLinearChange)}]) {
        [[DVSDK sharedInstance] adLinearChange:adId];
        [self.sentEvents addObject:@{ adId : @(LoopMeDVSDKEventTypeAdLinearChange)}];
    }
}

- (void)adPaused:(NSString *)adId {
    if (![self.sentEvents containsObject:@{ adId : @(LoopMeDVSDKEventTypeAdPaused)}]) {
        [[DVSDK sharedInstance] adPaused:adId];
        [self.sentEvents addObject:@{ adId : @(LoopMeDVSDKEventTypeAdPaused)}];
    }
}

- (void)adPlaying:(NSString *)adId {
    if (![self.sentEvents containsObject:@{ adId : @(LoopMeDVSDKEventTypeAdPlaying)}]) {
        [[DVSDK sharedInstance] adPlaying:adId];
        [self.sentEvents addObject:@{ adId : @(LoopMeDVSDKEventTypeAdPlaying)}];
    }
}

- (void)adFirstQuartile:(NSString *)adId {
    if (![self.sentEvents containsObject:@{ adId : @(LoopMeDVSDKEventTypeAdFirstQuartile)}]) {
        [[DVSDK sharedInstance] adFirstQuartile:adId];
        [self.sentEvents addObject:@{ adId : @(LoopMeDVSDKEventTypeAdFirstQuartile)}];
    }
}

- (void)adMidpoint:(NSString *)adId {
    if (![self.sentEvents containsObject:@{ adId : @(LoopMeDVSDKEventTypeAdMidpoint)}]) {
        [[DVSDK sharedInstance] adMidpoint:adId];
        [self.sentEvents addObject:@{ adId : @(LoopMeDVSDKEventTypeAdMidpoint)}];
    }
}

- (void)adThirdQuartile:(NSString *)adId {
    if (![self.sentEvents containsObject:@{ adId : @(LoopMeDVSDKEventTypeAdThirdQuartile)}]) {
        [[DVSDK sharedInstance] adThirdQuartile:adId];
        [self.sentEvents addObject:@{ adId : @(LoopMeDVSDKEventTypeAdThirdQuartile)}];
    }
}

- (void)adComplete:(NSString *)adId {
    if (![self.sentEvents containsObject:@{ adId : @(LoopMeDVSDKEventTypeAdComplete)}]) {
        [[DVSDK sharedInstance] adComplete:adId];
        [self.sentEvents addObject:@{ adId : @(LoopMeDVSDKEventTypeAdComplete)}];
    }
}

- (void)adVolumeChange:(NSString *)adId newVolumeLevel:(float)volume {
    if (![self.sentEvents containsObject:@{ adId : @(LoopMeDVSDKEventTypeAdVolumeChange)}]) {
        [[DVSDK sharedInstance] adVolumeChange:adId newVolumeLevel:volume];
        [self.sentEvents addObject:@{ adId : @(LoopMeDVSDKEventTypeAdVolumeChange)}];
    }
}

- (void)adDurationChange:(NSString *)adId newDuration:(float)duration {
    if (![self.sentEvents containsObject:@{ adId : @(LoopMeDVSDKEventTypeAdDurationChange)}]) {
        [[DVSDK sharedInstance] adDurationChange:adId newDuration:duration];
        [self.sentEvents addObject:@{ adId : @(LoopMeDVSDKEventTypeAdDurationChange)}];
    }
}

- (void)adResumedForView:(UIView *)playerView adId:(NSString *)adId {
    if (![self.sentEvents containsObject:@{ adId : @(LoopMeDVSDKEventTypeAdResumedForView)}]) {
        [[DVSDK sharedInstance] adResumedForView:playerView adId:adId];
        [self.sentEvents addObject:@{ adId : @(LoopMeDVSDKEventTypeAdResumedForView)}];
    }
}

- (void)adMute:(NSString *)adId {
    if (![self.sentEvents containsObject:@{ adId : @(LoopMeDVSDKEventTypeAdMute)}]) {
        [[DVSDK sharedInstance] adMute:adId];
        [self.sentEvents addObject:@{ adId : @(LoopMeDVSDKEventTypeAdMute)}];
    }
}
- (void)adEvent:(NSString *)eventName eventInfo:(NSDictionary *)eventInfo adId:(NSString *)adId {
    [[DVSDK sharedInstance] adEvent:eventName eventInfo:eventInfo adId:adId];
}


/**
 @abstract Sets the desired output format. This allows the implementer to see different levels of logs.
 @param sdkLoggerMode The desired output level.
 */
- (void)setLoggerMode:(LoggerMode)sdkLoggerMode {
    [[DVSDK sharedInstance] setLoggerMode:sdkLoggerMode];
}

- (void)clean {
    [self.sentEvents removeAllObjects];
}
@end
