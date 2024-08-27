//
//  LoopMeServerURLBuilder.m
//  LoopMeSDK
//
//  Created by Dmitriy Lihachov on 07/11/13.
//  Copyright (c) 2013 LoopMe. All rights reserved.
//
#import <AdSupport/AdSupport.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <SystemConfiguration/CaptiveNetwork.h>

#import "LoopMeSDK.h"
#import "LoopMeDefinitions.h"
#import "LoopMeIdentityProvider.h"
#import "LoopMeReachability.h"
#import "LoopMeServerURLBuilder.h"
#import "LoopMeTargeting.h"
#import "LoopMeLogging.h"
#import "NSData+LoopMeAES128.h"
#import "LoopMeORTBTools.h"

@implementation LoopMeServerURLBuilder

#pragma mark - Class Methods

+ (NSString *)packageIDs {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    parameters[@"vt"] = [LoopMeIdentityProvider advertisingTrackingDeviceIdentifier];
    parameters[@"av"] = [self parameterForApplicationVersion];
    parameters[@"or"] = [self parameterForOrientation];
    parameters[@"tz"] = [self parameterForTimeZone];
    parameters[@"lng"] = [self parameterForLanguage];
    parameters[@"cn"] = [self parameterForConnectionType];
    parameters[@"dnt"] = [self parameterForDNT];
    parameters[@"bundleid"] = [self parameterForBundleIdentifier];
    parameters[@"wn"] = [self parameterForWiFiName];
    parameters[@"sv"] = [NSString stringWithFormat:@"%@", LOOPME_SDK_VERSION];
    parameters[@"mr"] = @"0";
    parameters[@"plg"] = [self parameterForBatteryState];
    parameters[@"chl"] = [NSString stringWithFormat:@"%f", [UIDevice currentDevice].batteryLevel];
    
    NSMutableString *parametersString = [[NSMutableString alloc] init];
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [parametersString appendFormat:@"%@=%@&", key, value];
    }];
    parametersString = [[parametersString substringToIndex:[parametersString length]-1] mutableCopy];

    NSData *plain = [parametersString dataUsingEncoding:NSUTF8StringEncoding];

    NSData *cipher = [plain lm_AES128Encrypt];
    return [cipher base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}


#pragma warning -- dublicated implemintation

+ (NSString *)parameterForUniqueIdentifier {
    return [LoopMeIdentityProvider advertisingTrackingDeviceIdentifier];
}

+ (NSString *)parameterForLanguage {
    return [NSLocale preferredLanguages][0];
}

+ (NSString *)parameterForOrientationThreadUnsafe{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    return UIInterfaceOrientationIsPortrait(orientation) ? @"p" : @"l";
}

+ (NSString *)parameterForOrientation {
  __block NSString *orientationString;
    if ([NSThread isMainThread]){
        orientationString = [self parameterForOrientationThreadUnsafe];
    }else{
        dispatch_sync(dispatch_get_main_queue(), ^{
            orientationString = [self parameterForOrientationThreadUnsafe];
        });
    }

  return orientationString;
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

+ (NSString *)parameterForConnectionType {
    return [NSString stringWithFormat:@"%lu", (long)[[LoopMeReachability reachabilityForLocalWiFi] connectionType]];
}

+ (NSString *)parameterForApplicationVersion {
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
}

+ (NSString *)parameterForDNT {
    return ([LoopMeIdentityProvider advertisingTrackingEnabled] ? @"0" : @"1");
}

+ (NSString *)parameterForWiFiName {
    return [self fetchSSIDInfo][@"SSID"];
}

+ (NSString *)parameterForBundleIdentifier {
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    return bundleIdentifier ? [self escapeString:bundleIdentifier] : @"";
}

+ (NSString *)parameterForBatteryState {
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    UIDeviceBatteryState currentState = [[UIDevice currentDevice] batteryState];
    if (currentState != UIDeviceBatteryStateUnknown) {
        if (currentState == UIDeviceBatteryStateUnplugged) {
            return @"NCHRG";
        } else {
            return @"CHRG";
        }
    }
    return @"UNKNOWN";
}

+ (NSString *)parameterForScreenWidth {
    return [NSString stringWithFormat:@"%1.0f", [[UIScreen mainScreen] bounds].size.width];
}

+ (NSString *)parameterForScreenHeight {
    return [NSString stringWithFormat:@"%1.0f", [[UIScreen mainScreen] bounds].size.height];
}

+ (NSString *)buildParameters:(NSMutableDictionary *)parameters {
    NSMutableString *parametersString = [[NSMutableString alloc] init];
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [parametersString appendFormat:@"%@=%@&", [self escapeString:key], [self escapeString:value]];
    }];
    return  [@"?" stringByAppendingString:[parametersString substringToIndex:[parametersString length]-1]];
}

+ (NSString *)escapeString:(NSString*)string {
    
    NSString *unreserved = @"-._~/?";
    NSMutableCharacterSet *allowed = [NSMutableCharacterSet
                                      alphanumericCharacterSet];
    [allowed addCharactersInString:unreserved];
    return [string stringByAddingPercentEncodingWithAllowedCharacters:allowed];
}

+ (NSDictionary *)fetchSSIDInfo {
    NSArray *interfaceNames = CFBridgingRelease(CNCopySupportedInterfaces());
    NSDictionary *SSIDInfo;
    for (NSString *interfaceName in interfaceNames) {
        SSIDInfo = CFBridgingRelease(
                                     CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName));
        LoopMeLogDebug(@"%s: %@ => %@", __func__, interfaceName, SSIDInfo);
        
        BOOL isNotEmpty = (SSIDInfo.count > 0);
        if (isNotEmpty) {
            break;
        }
    }
    return SSIDInfo;
}

@end
