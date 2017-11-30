//
//  LoopMeORTBTools.m
//  Tester
//
//  Created by Bohdan on 4/5/17.
//  Copyright © 2017 LoopMe. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "LoopMeDefinitions.h"
#import "LoopMeReachability.h"
#import "LoopMeGeoLocationProvider.h"
#import "NSString+Encryption.h"
#import "LoopMeTargeting.h"
#import "LoopMeIdentityProvider.h"
#import "LoopMeORTBTools.h"

static NSString *_userAgent;
NSString * const kLoopMeInterfaceOrientationPortrait = @"p";
NSString * const kLoopMeInterfaceOrientationLandscape = @"l";

typedef NS_ENUM(long, LoopMeDeviceCharge) {
    LoopMeDeviceChargeOff = 0,
    LoopMeDeviceChargeOn = 1,
    LoopMeDeviceChargeUnknown = -1,
};

@implementation LoopMeORTBTools

+ (NSData *)makeRequestBodyWithAppKey:(NSString *)appKey
                            targeting:(LoopMeTargeting *)targeting
                      integrationType:(NSString *)integrationType adSpotSize:(CGSize)size {
    NSData *jsonData;
    
    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    request[@"id"] = [[NSUUID UUID] UUIDString];
    request[@"imp"] = @[[self impressionObject:size integrationType:integrationType]];
    request[@"app"] = [self appObject:appKey];
    request[@"device"] = [self deviceObject];
    
    if (targeting) {
        request[@"user"] = [self userObject:targeting];
    }
    
    request[@"tmax"] = @250;
    request[@"bcat"] = @[@"IAB25-3",
                         @"IAB25",
                         @"IAB26"];
    
    NSError *error;
    jsonData = [NSJSONSerialization dataWithJSONObject:request options:NSJSONWritingPrettyPrinted error:&error];
    
    return jsonData;
}

+ (NSDictionary *)appObject:(NSString *)appKey {
    NSMutableDictionary *app = [[NSMutableDictionary alloc] init];
    
    app[@"id"] = appKey;
    app[@"name"] = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    app[@"bundle"] = [self parameterForBundleIdentifier];
    app[@"version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    return app;
}

+ (NSDictionary *)userObject:(LoopMeTargeting *)targeting {
    NSMutableDictionary *user = [[NSMutableDictionary alloc] init];
    user[@"gender"] = targeting.genderParameter;
    user[@"yob"] = @(targeting.yearOfBirth);
    user[@"keywords"] = targeting.keywords;
    
    return user;
}

+ (NSDictionary *)deviceObject {
    NSMutableDictionary *device = [[NSMutableDictionary alloc] init];
    
    device[@"dnt"] = [self parameterForDNT];
    device[@"ua"] = [self userAgent];
    
    if ([[LoopMeGeoLocationProvider sharedProvider] isLocationUpdateEnabled] && [[LoopMeGeoLocationProvider sharedProvider] isValidLocation]) {
        
        NSDictionary *geo = @{@"lat" : [NSString stringWithFormat:@"%0.4f", (float)[LoopMeGeoLocationProvider sharedProvider].location.coordinate.latitude], @"lon" : [NSString stringWithFormat:@"%0.4f", (float)[LoopMeGeoLocationProvider sharedProvider].location.coordinate.longitude], @"type" : @1};
        
        device[@"geo"] = geo;
    }
    
    device[@"language"] = [self parameterForLanguage];
    device[@"make"] = @"Apple";
    device[@"model"] = [LoopMeIdentityProvider deviceType];
    device[@"os"] = @"iOS";
    device[@"hwv"] = [LoopMeIdentityProvider deviceModel];
    device[@"osv"] = [[UIDevice currentDevice] systemVersion];
    device[@"js"] = @1;
    device[@"devicetype"] = @([LoopMeIdentityProvider deviceTypeNum]);
    device[@"connectiontype"] = @([self parameterForConnectionType]);
    device[@"ifa"] = [LoopMeIdentityProvider advertisingTrackingDeviceIdentifier];
    device[@"w"] = @([[UIScreen mainScreen] bounds].size.width);
    device[@"h"] = @([[UIScreen mainScreen] bounds].size.height);
    device[@"ext"] = @{@"phonename" : [LoopMeIdentityProvider phoneName], @"plugin" : @([self parameterForBatteryState]), @"chargelevel" : [NSString stringWithFormat:@"%f", [UIDevice currentDevice].batteryLevel], @"wifiname" : [self parameterForWiFiName], @"orientation" : [self parameterForOrientation], @"timezone" : [self parameterForTimeZone]};
    
    return device;
}

+ (NSDictionary *)impressionObject:(CGSize)size
                   integrationType:(NSString *)integrationType {
    NSMutableDictionary *impression = [[NSMutableDictionary alloc] init];
    impression[@"id"] = @1;
    impression[@"displaymanager"] = @"LOOPME_SDK";
    impression[@"displaymanagerver"] = LOOPME_SDK_VERSION;
    impression[@"instl"] = @1; //TODO: now hardcoded
    impression[@"bidfloor"] = @0;
    impression[@"secure"] = @1;
    impression[@"video"] = [self videoObject:size];
    impression[@"banner"] = [self bannerObject:size];
    impression[@"metric"] = [self parameterForAvailableTrackers];
    impression[@"ext"] = @{@"it" : integrationType, @"supported_techs" : @[@"VIDEO - for usual MP4 video", @"VAST2", @"VAST3", @"VAST4", @"VPAID1", @"VPAID2", @"MRAID2", @"V360"]};

    return impression;
}

+ (NSDictionary *)videoObject:(CGSize)size {
    NSMutableDictionary *video = [[NSMutableDictionary alloc] init];
    
    video[@"mimes"] = @[@"video/mp4"];
    video[@"minduration"] = @5;
    video[@"maxduration"] = @30;
    video[@"protocols"] = @[@2, @3];
    video[@"startdelay"] = @0;
    video[@"linearity"] = @1;
    video[@"sequence"] = @1;
    video[@"battr"] = @[@3, @8];
    video[@"maxbitrate"] = @1024;
    video[@"boxingallowed"] = @1;
    video[@"delivery"] = @[@2];
    video[@"w"] = @(size.width);
    video[@"h"] = @(size.height);
    
    return video;
}

+ (NSDictionary *)bannerObject:(CGSize)size {
    NSMutableDictionary *banner = [[NSMutableDictionary alloc] init];
    
    banner[@"w"] = @(size.width);
    banner[@"h"] = @(size.height);
    banner[@"id"] = @1;
    banner[@"battr"] = @[@3, @8];
    banner[@"api"] = @[@3, @5];
    
    return banner;
}

+ (LoopMeDeviceCharge)parameterForBatteryState {
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    UIDeviceBatteryState currentState = [[UIDevice currentDevice] batteryState];
    if (currentState != UIDeviceBatteryStateUnknown) {
        if (currentState == UIDeviceBatteryStateUnplugged) {
            return LoopMeDeviceChargeOff;
        } else {
            return LoopMeDeviceChargeOn;
        }
    }
    return LoopMeDeviceChargeUnknown;
}

+ (NSString *)parameterForTimeZone {
    static NSDateFormatter *formatter;
    @synchronized(self) {
        if (!formatter) {
            formatter = [[NSDateFormatter alloc] init];
        }
    }
    [formatter setDateFormat:@"Z"];
    NSDate *today = [NSDate date];
    return [formatter stringFromDate:today];
}

+ (NSString *)parameterForOrientation {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    return UIInterfaceOrientationIsPortrait(orientation) ?
    kLoopMeInterfaceOrientationPortrait :
    kLoopMeInterfaceOrientationLandscape;
}

+ (NSInteger)parameterForConnectionType {
    return [[LoopMeReachability reachabilityForLocalWiFi] connectionType];
}

+ (NSString *)parameterForBundleIdentifier {
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    return bundleIdentifier ? [bundleIdentifier lm_stringByAddingPercentEncodingForRFC3986] : @"";
}

+ (NSString *)parameterForDNT {
    return ([LoopMeIdentityProvider advertisingTrackingEnabled] ? @"0" : @"1");
}

+ (NSString *)parameterForWiFiName {
    return [[LoopMeReachability reachabilityForLocalWiFi] getSSID];
}

+ (NSString *)parameterForLanguage {
    return [NSLocale preferredLanguages][0];
}

+ (NSString *)userAgent {
    if (_userAgent == nil) {
        _userAgent = [[[UIWebView alloc] init] stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    }
    return _userAgent;
}

+ (NSArray *)parameterForAvailableTrackers {
    NSArray *vendors = [self viewabilityVendors];
    NSMutableArray *parameter = [[NSMutableArray alloc] init];
    for (NSString *vendor in vendors) {
        [parameter addObject:@{@"type" : @"viewability", @"vendor" : vendor}];
    }
    return parameter;
}

+ (NSArray *)viewabilityVendors {
    return @[@"moat"];
}

@end
