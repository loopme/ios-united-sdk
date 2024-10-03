//
//  LoopMeORTBTools.m
//  LoopMeSDK
//
//  Created by Bohdan on 4/5/17.
//  Copyright © 2017 LoopMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <LoopMeUnitedSDK/LoopMeUnitedSDK-Swift.h>
#import <AdSupport/ASIdentifierManager.h>

#import "LoopMeDefinitions.h"
#import "LoopMeReachability.h"
#import "NSString+Encryption.h"
#import "LoopMeTargeting.h"
#import "LoopMeIdentityProvider.h"
#import "LoopMeORTBTools.h"
#import "LoopMeGDPRTools.h"
#import "LoopMeAudioCheck.h"
#import "LoopMeGlobalSettings.h"
#import "LoopMeErrorEventSender.h"
#import "LoopMeSDK.h"

static NSString *_userAgent;

@interface LoopMeORTBTools ()

@property (nonatomic, assign) BOOL isInterstitial;
@property (nonatomic, assign) BOOL isRewarded;

@end

@implementation LoopMeORTBTools

- (instancetype)initWithAppKey: (NSString *)appKey
                     targeting: (LoopMeTargeting *)targeting
                    adSpotSize: (CGSize)size
               integrationType: (NSString *)integrationType
                isInterstitial: (BOOL)isInterstitial
                    isRewarded: (BOOL)isRewarded {
    self = [super init];
    if (self) {
        self.appKey = appKey;
        self.targeting = targeting;
        self.integrationType = integrationType ?: @"normal";
        self.size = size;
        self.isInterstitial = isInterstitial;
        self.isRewarded = isRewarded;
    }
    return self;
}

- (NSData *)makeRequestBody {
    LoopMeGDPRTools *gdpr = [LoopMeGDPRTools sharedInstance];
    BOOL isGDPR = [gdpr cmpSdkID] && [gdpr GDRRApplies] != -1;
    BOOL isLiveDebug = [LoopMeGlobalSettings sharedInstance].liveDebugEnabled;
    BOOL canSetIfa = ([LoopMeIdentityProvider appTrackingTransparencyEnabled] && [ASIdentifierManager sharedManager].isAdvertisingTrackingEnabled);

    NSMutableDictionary *request = [[NSMutableDictionary alloc] initWithDictionary: @{
        @"id": [[NSUUID UUID] UUIDString],
        @"source": @{
            @"ext": @{@"omidpn": @"Loopme", @"omidpv": [self sdkVersion]}
        },
        @"events": @{
            @"ext": @{@"omidpn": @"Loopme", @"omidpv": [self sdkVersion]},
            @"apis": @[@7]
        },
        @"app": @{
            @"id": self.appKey,
            @"bundle": [self parameterForBundleIdentifier],
            @"name": [[NSBundle mainBundle] infoDictionary][@"CFBundleName"],
            @"ver": [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"],
            @"domain": [self parameterForBundleIdentifier]
        },
        @"imp": @[[self mutableWithDictionary: @{
            @"id": @1,
            @"displaymanager": @"LOOPME_SDK",
            @"displaymanagerver": [self sdkVersion],
            @"instl": self.isInterstitial ? @1 : @0,
            @"rwdd": self.isRewarded ? @1 : @0,
            @"bidfloor": @0,
            @"secure": @1,
            @"ext": @{
                @"it": self.integrationType,
                @"skadn": @{
                    @"versions": @[@"2.0", @"2.1", @"2.2", @"3.0", @"4.0"],
                    @"sourceapp": [self parameterForBundleIdentifier],
                    @"skadnetids": [self skadnetids: [[NSBundle mainBundle] infoDictionary][@"SKAdNetworkItems"]]
                }
            },
            @"banner": self.banner ? @{
                @"w": @(self.size.width),
                @"h": @(self.size.height),
                @"id": @1,
                @"battr": @[@3, @8],
                @"api": @[@2, @5, @7],
            } : [NSNull null],
        }]],
        @"device": [self mutableWithDictionary: @{
            @"make": @"Apple",
            @"os": @"iOS",
            @"js": @1,
            @"pxratio": @([UIScreen mainScreen].scale),
            @"dnt": [LoopMeIdentityProvider advertisingTrackingEnabled] ? @"0" : @"1",
            @"model": [LoopMeIdentityProvider deviceType],
            @"hwv": [LoopMeIdentityProvider deviceModel],
            @"devicetype": @([LoopMeIdentityProvider deviceTypeNum]),
            @"ifa": [LoopMeIdentityProvider advertisingTrackingDeviceIdentifier],
            @"ua": [UserAgent defaultUserAgent],
            @"language": [NSLocale preferredLanguages][0],
            @"osv": [[UIDevice currentDevice] systemVersion],
            @"connectiontype": @([[LoopMeReachability reachabilityForLocalWiFi] connectionType]),
            @"w": @([[UIScreen mainScreen] bounds].size.width),
            @"h": @([[UIScreen mainScreen] bounds].size.height),
            @"ext": [self mutableWithDictionary: @{
                @"ifv": [[UIDevice currentDevice] identifierForVendor].UUIDString,
                @"atts": [LoopMeIdentityProvider customAuthorizationStatus],
                @"plugin": [self batterryState],
                @"chargelevel": [self batteryChargeLevel],
                @"batterysaver": [LoopMeIdentityProvider isLowPowerModeEnabled],
                @"batterylevel": @([LoopMeIdentityProvider batteryLevel]),
                @"orientation": UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? @"p" : @"l",
                @"timezone": [self timezone],
                @"ifa": canSetIfa ? [LoopMeIdentityProvider advertisingTrackingDeviceIdentifier] : [NSNull null],
                // TODO: Why it's needed?
                @"audio_outputs": isLiveDebug ? [[LoopMeAudioCheck shared] currentOutputs] : [NSNull null],
                @"music": isLiveDebug ? @([[LoopMeAudioCheck shared] isAudioPlaying] ? 1 : 0) : [NSNull null]
            }]
        }],
        @"consent_type": ![[LoopMeGDPRTools getConsentValue] boolValue] ? @([gdpr consentType]) : [NSNull null],
        @"consent": [LoopMeGDPRTools getConsentValue],
        @"regs": @{
            @"coppa": @0,
            @"ext": isGDPR ? @{
                @"gdpr": @([gdpr GDRRApplies])
            } : @{
                @"us_privacy": [LoopMeCCPATools ccpaString]
            }
        },
        @"user": self.targeting ? @{
            @"gender": self.targeting.genderParameter,
            @"yob": @(self.targeting.yearOfBirth),
            @"keywords": self.targeting.keywords,
            @"consent": [LoopMeGDPRTools getConsentValue],
            @"ext": @{
                @"sessionduration": [[LoopMeLifecycleManager shared] timeElapsedSinceStart],
                @"impdepth": @([[LoopMeLifecycleManager shared] sessionDepthForAppKey: self.appKey])
            }
        } : @{@"ext": @{
            @"sessionduration": [[LoopMeLifecycleManager shared] timeElapsedSinceStart],
            @"impdepth": @([[LoopMeLifecycleManager shared] sessionDepthForAppKey: self.appKey])
        },
              @"consent": [LoopMeGDPRTools getConsentValue]},
        @"tmax": @700,
        @"bcat": @[@"IAB25-3", @"IAB25", @"IAB26"]
    }];
    
    request[@"ext"] = (self.video && self.isRewarded) ?
        @{ @"sdk_init_time": @([LoopMeSDK.shared getSdkInitTime]), @"placementType": @"rewarded" } :
        @{ @"sdk_init_time": @([LoopMeSDK.shared getSdkInitTime]) };
    
    if (self.video) {
        request[@"imp"][0][@"video"] = self.isRewarded ? [self rewardedVideo: self.size] : [self video: self.size];
    }

    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: cleanNullsFromCollection(request)
                                                       options: NSJSONWritingPrettyPrinted
                                                         error: &error];
    if (!jsonData) {
        NSString *errorMessage = [NSString stringWithFormat: @"OpenRTB Request JSON Serialization Error %@", error.localizedDescription];
        [LoopMeErrorEventSender sendError: LoopMeEventErrorTypeCustom
                             errorMessage: errorMessage
                                     info: @{kErrorInfoClass: @"LoopMeORTBTools", kErrorInfoAppKey: self.appKey}];
    }
    return jsonData;
}

- (NSDictionary *)video:(CGSize)size {
    return @{
        @"mimes": @[@"video/mp4"],
        @"minduration": @5,
        @"maxduration": @999,
        @"protocols": @[@2, @3, @7, @8],
        @"startdelay": @0,
        @"linearity": @1,
        @"sequence": @1,
        @"battr": @[@3, @8],
        @"maxbitrate": @1024,
        @"boxingallowed": @1,
        @"delivery": @[@2],
        @"api": @[@2, @5, @7],
        @"w": @(size.width),
        @"h": @(size.height),
        @"companiontype": @[@1],
        @"companionad": @[@{
            @"w": @(size.width),
            @"h": @(size.height),
            @"format": @[@{
                @"w": @(size.width),
                @"h": @(size.height),
            }]
        }],
        @"ext": @{
            @"rewarded": @0
        },
        @"skip": @1,
        @"rwdd": @0,
        @"skipafter": @5,
    };
}

- (NSDictionary *)rewardedVideo:(CGSize)size {
    NSMutableDictionary *rewardedVideo = [[NSMutableDictionary alloc] initWithDictionary: [self video: size]];
    [rewardedVideo addEntriesFromDictionary:@{
        @"skip": @0,
        @"rwdd": @1,
        @"skipafter": @0,
        @"skipmin": @0,
        @"ext": @{
            @"rewarded": @1,
            @"videotype": @"rewarded"
        }
    }];
    return rewardedVideo;
}

- (NSNumber *)batterryState {
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    return @{
        @(UIDeviceBatteryStateUnknown): @-1,
        @(UIDeviceBatteryStateUnplugged): @0,
        @(UIDeviceBatteryStateCharging): @1,
        @(UIDeviceBatteryStateFull): @1
    }[@([UIDevice currentDevice].batteryState)];
}

- (NSString *)batteryChargeLevel {
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    return [NSString stringWithFormat: @"%f", [UIDevice currentDevice].batteryLevel];
}

- (NSString *)timezone {
    static NSDateFormatter *formatter;
    @synchronized(self) {
        if (!formatter) {
            formatter = [[NSDateFormatter alloc] init];
        }
    }
    [formatter setDateFormat: @"Z"];
    return [formatter stringFromDate: [NSDate date]];
}

- (NSMutableArray *)skadnetids: (NSArray *)skAdNetworkItems {
    NSMutableArray *skAdIdentifiers = [NSMutableArray array];
    for (NSDictionary *skAdNetworkItem in skAdNetworkItems) {
        NSString *skAdNetworkIdentifier = skAdNetworkItem[@"SKAdNetworkIdentifier"];
        if (skAdNetworkIdentifier != nil) {
            [skAdIdentifiers addObject: skAdNetworkIdentifier];
        }
    }
    return skAdIdentifiers;
}

- (NSString *)parameterForBundleIdentifier {
    return [([[NSBundle mainBundle] bundleIdentifier] ?: @"") lm_stringByAddingPercentEncodingForRFC3986];
}

- (NSString *)sdkVersion {
    return [[NSBundle bundleForClass: LoopMeORTBTools.class].infoDictionary objectForKey: @"CFBundleShortVersionString"];
}

- (NSMutableDictionary *)mutableWithDictionary:(NSDictionary *)dictionary {
    return [[NSMutableDictionary alloc] initWithDictionary: dictionary];
}

id cleanNullsFromCollection(id collection) {
    if ([collection isKindOfClass: [NSArray class]]) {
        NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity: [collection count]];
        for (id item in collection) {
            [mutableArray addObject: cleanNullsFromCollection(item)];
        }
        return [mutableArray copy];
    } else if ([collection isKindOfClass: [NSDictionary class]]) {
        NSMutableDictionary *mutableDict = [NSMutableDictionary dictionaryWithDictionary: collection];
        for (id key in [collection allKeys]) {
            id value = collection[key];
            if (value == [NSNull null]) {
                [mutableDict removeObjectForKey: key];
            } else {
                mutableDict[key] = cleanNullsFromCollection(value);
            }
        }
        return [mutableDict copy];
    }
    return collection;
}

- (BOOL)validateRequestData:(NSData *)data {
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

    if (error || !jsonDict) {
        NSLog(@"Validation failed: Invalid input data. Error: %@", error.localizedDescription);
        return NO;
    }

    @try {
        // Define validation rules
        NSArray *validations = @[
            @{@"field": jsonDict[@"app"][@"id"], @"rules": @[@"required"]},
            @{@"field": jsonDict[@"source"][@"ext"][@"omidpn"], @"rules": @[@"required"]},
            @{@"field": jsonDict[@"source"][@"ext"][@"omidpv"], @"rules": @[@"required"]},
            @{@"field": jsonDict[@"events"][@"ext"][@"omidpn"], @"rules": @[@"required"]},
            @{@"field": jsonDict[@"events"][@"ext"][@"omidpv"], @"rules": @[@"required"]},
            self.banner ? @{@"field": jsonDict[@"imp"][0][@"banner"][@"w"], @"rules": @[@"required", @"gt0"]} : @{},
            self.banner ? @{@"field": jsonDict[@"imp"][0][@"banner"][@"h"], @"rules": @[@"required", @"gt0"]} : @{},
            self.video ? @{@"field": jsonDict[@"imp"][0][@"video"][@"w"], @"rules": @[@"required", @"gt0"]} : @{},
            self.video ? @{@"field": jsonDict[@"imp"][0][@"video"][@"h"], @"rules": @[@"required", @"gt0"]} : @{}
        ];

        for (NSDictionary *validation in validations) {
            NSString *field = validation[@"field"];
            NSArray *rules = validation[@"rules"];

            // If validation dictionary is empty, skip it
            if ([validation count] == 0) continue;

            if (![self isValidField:field inJSON:jsonDict withRules:rules]) {
                return NO;
            }
        }

    } @catch (NSException *exception) {
        NSLog(@"Validation failed: An error occurred during validation. Exception: %@", exception.reason);
        return NO;
    }
    return YES;
}

#pragma mark - Helper Methods

- (BOOL)isValidField:(NSString *)field inJSON:(NSDictionary *)jsonDict withRules:(NSArray *)rules {

    for (NSString *rule in rules) {
        if ([rule isEqualToString:@"required"]) {
            if (![self isValidRequiredField:field]) {
                NSLog(@"Validation failed: %@ is required and missing or empty.", field);
                return NO;
            }
        }
        if ([rule isEqualToString:@"gt0"]) {
            if (![self isValidGreaterThanZero:field]) {
                NSLog(@"Validation failed: %@ must be greater than 0.", field);
                return NO;
            }
        }
    }
    return YES;
}

- (BOOL)isValidRequiredField:(id)fieldValue {
    return (fieldValue && ([fieldValue isKindOfClass:[NSString class]] ? [fieldValue length] > 0 : YES));
}

- (BOOL)isValidGreaterThanZero:(id)fieldValue {
    return ([fieldValue isKindOfClass:[NSNumber class]] && [fieldValue integerValue] > 0);
}

@end
