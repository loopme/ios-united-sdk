//
//  DVSDK.h
//  DVSDK
//
//  Created by Daniel Gorlovetsky on 25/11/2015.
//  Copyright © 2015 DoubleVerify. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DVVideoSDKDelegate.h"
#import "DVSDKInitDelegate.h"

#define DV_SDK_VERSION 1.581f

/// @abstract Notifications that are being sent via NSNotificationCenter are documented below.
/// @abstract To get the notifications when they are being sent, please register to one or more of the notification names below.

#define VIEWABILITY_PCT_CHANGED_NOTIFICATION        @"VIEWABILITY_PCT_CHANGED_NOTIFICATION"
#define VIEWABILITY_STATE_CHANGED_NOTIFICATION      @"VIEWABILITY_STATE_CHANGED_NOTIFICATION"
#define BUCKETS_ARRAY_CHANGED_NOTIFICATION          @"BUCKETS_ARRAY_CHANGED_NOTIFICATION"
#define VOLUME_BUCKETS_ARRAY_CHANGED_NOTIFICATION   @"VOLUME_BUCKETS_ARRAY_CHANGED_NOTIFICATION"
#define BUCKETS_ARRAY_CLEAR_NOTIFICATION            @"BUCKETS_ARRAY_CLEAR_NOTIFICATION"
#define MESSAGE_SENT_NOTIFICATION                   @"MESSAGE_SENT_NOTIFICATION"

/*!
 @abstract Categorizes log types.
 @constant kLoggerModeDefault The default implementation of output, as developed and recommended by DoubleVerify.
 @constant kLoggerModeDebug All available output will be printed and sent, this is mainly helpful when trying to debug this SDK.
 */
typedef enum {
    kLoggerModeDefault = 0,
    kLoggerModeDebug
} LoggerMode;

@interface DVSDK : NSObject

+ (instancetype)sharedInstance;

/**
 @abstract Initializes the SDK and starts it's activity.
 @param apiKey The API key, as provided by DoubleVerify's Account Management Team.
*/
- (void)initWithAPIKey:(NSString *)apiKey;

/**
 @abstract Initializes the SDK and starts it's activity.
 @param apiKey The API key, as provided by DoubleVerify's Account Management Team.
 @param delegate delegate
 */
- (void)initWithAPIKey:(NSString *)apiKey delegate:(id<DVSDKInitDelegate>)delegate;

/**
 @abstract get sdk version
 */
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

@end
