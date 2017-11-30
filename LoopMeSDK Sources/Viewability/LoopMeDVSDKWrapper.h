//
//  LoopMeDVSDKWrapper.h
//  Tester
//
//  Created by Bohdan on 12/15/16.
//  Copyright © 2016 LoopMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DVSDK/DVSDK.h>

@interface LoopMeDVSDKWrapper : NSObject

+ (instancetype)sharedInstance;

- (void)initWithAPIKey:(NSString *)apiKey;

- (void)initWithAPIKey:(NSString *)apiKey delegate:(id<DVSDKInitDelegate>)delegate;
+ (float)getVersion;

/**
 @abstract stop/resume sdk operation
 */
- (void)stopTracking;
- (void)resumeTracking;

/**
 @abstract display tracking API
 */
- (void)startMeasuringAd:(UIView *)adView;
- (void)stopMeasuringAd:(UIView *)adView;

/**
 @abstract Video tracking API
 */
- (void)adLoadedView:(UIView *)playerView withCallback:(id<DVVideoSDKDelegate>)callback vastFile:(NSString *)vastFileContent adId:(NSString *)adId;
- (void)adStartedForView:(UIView *)playerView adId:(NSString *)adId;
- (void)adStopped:(NSString *)adId;
- (void)adImpression:(NSString *)adId;
- (void)adLinearChange:(NSString *)adId;
- (void)adPaused:(NSString *)adId;
- (void)adPlaying:(NSString *)adId;
- (void)adFirstQuartile:(NSString *)adId;
- (void)adMidpoint:(NSString *)adId;
- (void)adThirdQuartile:(NSString *)adId;
- (void)adComplete:(NSString *)adId;
- (void)adVolumeChange:(NSString *)adId newVolumeLevel:(float)volume;
- (void)adDurationChange:(NSString *)adId newDuration:(float)duration;
- (void)adResumedForView:(UIView *)playerView adId:(NSString *)adId;
- (void)adMute:(NSString *)adId;
- (void)adEvent:(NSString *)eventName eventInfo:(NSDictionary *)eventInfo adId:(NSString *)adId;

/**
 @abstract Sets the desired output format. This allows the implementer to see different levels of logs.
 @param sdkLoggerMode The desired output level.
 */
- (void)setLoggerMode:(LoggerMode)sdkLoggerMode;

- (void)clean;

@end
