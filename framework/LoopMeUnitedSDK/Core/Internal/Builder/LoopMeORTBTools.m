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
#import "LoopMeGeoLocationProvider.h"
#import "NSString+Encryption.h"
#import "LoopMeTargeting.h"
#import "LoopMeIdentityProvider.h"
#import "LoopMeORTBTools.h"
#import "LoopMeGDPRTools.h"
#import "LoopMeAudioCheck.h"
#import "LoopMeGlobalSettings.h"

static NSString *_userAgent;
NSString * const kLoopMeInterfaceOrientationPortrait = @"p";
NSString * const kLoopMeInterfaceOrientationLandscape = @"l";

typedef NS_ENUM(long, LoopMeDeviceCharge) {
    LoopMeDeviceChargeOff = 0,
    LoopMeDeviceChargeOn = 1,
    LoopMeDeviceChargeUnknown = -1,
};

@interface LoopMeORTBTools ()

@property (nonatomic, assign) BOOL isInterstitial;

@end

@implementation LoopMeORTBTools

- (instancetype)initWithAppKey:(NSString *)appKey
                     targeting:(LoopMeTargeting *)targeting
                    adSpotSize:(CGSize)size
               integrationType:(NSString *)integrationType
                isInterstitial:(BOOL)isInterstitial {
    self = [super init];
    if (self) {
        self.appKey = appKey;
        self.targeting = targeting;
        self.integrationType = integrationType;
        self.size = size;
        self.isInterstitial = isInterstitial;
    }
    return self;
}

- (NSData *)makeRequestBody {
    NSData *jsonData;
    
    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    request[@"id"] = [[NSUUID UUID] UUIDString];
    request[@"source"] = [self sourceObject];
    request[@"events"] = [self eventsObject];
    request[@"imp"] = @[[self impressionObject:self.size integrationType:self.integrationType]];
    request[@"app"] = [self appObject:self.appKey];
    request[@"device"] = [self deviceObject];
    request[@"regs"] = [self regsObject];
    request[@"user"] = [self userObject:self.targeting];
    
    request[@"tmax"] = @700;
    request[@"bcat"] = @[@"IAB25-3",
                         @"IAB25",
                         @"IAB26"];
    
    NSString *consentValue = [self getConsentValue];
    request[@"consent"] = consentValue;
    if (![consentValue boolValue]) {
        request[@"consent_type"] = @([[LoopMeGDPRTools sharedInstance] consentType]);
    }
    
    NSError *error;
    jsonData = [NSJSONSerialization dataWithJSONObject:request options:NSJSONWritingPrettyPrinted error:&error];
    
    return jsonData;
}

- (NSDictionary *)sourceObject {
    NSMutableDictionary *source = [[NSMutableDictionary alloc] init];
    source[@"ext"] = @{ @"omidpn": @"Loopme",
        @"omidpv": [self sdkVersion] };
    return source;
}

- (NSString *)getConsentValue {
    if ([[LoopMeGDPRTools sharedInstance] userConsentString]) {
        return [[LoopMeGDPRTools sharedInstance] userConsentString];
    } else {
        int gdpr = 0;
        if ([LoopMeIdentityProvider advertisingTrackingEnabled]) {
            gdpr = [[LoopMeGDPRTools sharedInstance] isUserConsent] ? 1 : 0;
        }
        return [NSString stringWithFormat:@"%d", gdpr];
    }
}

- (NSDictionary *)eventsObject {
    NSMutableDictionary *events = [[NSMutableDictionary alloc] init];
    events[@"ext"] = @{ @"omidpn": @"Loopme",
        @"omidpv": [self sdkVersion] };
    events[@"apis"] = @[@7];
    return events;
}

- (NSDictionary *)regsObject {
    NSMutableDictionary *regs = [[NSMutableDictionary alloc] init];
    regs[@"coppa"] = @0;
    if ([[LoopMeGDPRTools sharedInstance] cmpSdkID] && [[LoopMeGDPRTools sharedInstance] GDRRApplies] != -1) {
        NSInteger applies = [[LoopMeGDPRTools sharedInstance] GDRRApplies];
        regs[@"ext"] = @{@"gdpr" : @(applies)};
    }
    NSString *ccpaString = [LoopMeCCPATools ccpaString];
    if (ccpaString) {
        regs[@"ext"] = @{@"us_privacy" : ccpaString};
    }
    
    return regs;
}

- (NSDictionary *)appObject:(NSString *)appKey {
    NSMutableDictionary *app = [[NSMutableDictionary alloc] init];
    
    app[@"id"] = appKey;
    app[@"name"] = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    app[@"bundle"] = [self parameterForBundleIdentifier];
    app[@"version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    return app;
}

- (NSDictionary *)userObject:(LoopMeTargeting *)targeting {
    NSMutableDictionary *user = [[NSMutableDictionary alloc] init];
    
    if (targeting) {
        user[@"gender"] = targeting.genderParameter;
        user[@"yob"] = @(targeting.yearOfBirth);
        user[@"keywords"] = targeting.keywords;
    }
    
    NSMutableDictionary *ext = [[NSMutableDictionary alloc] init];
    
    user[@"ext"] = ext;

    return user;
}

- (NSDictionary *)deviceObject {
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
    device[@"ext"] = [self extForDevice];
    
    return device;
}

- (NSDictionary *)extForDevice {
    NSMutableDictionary *ext = [[NSMutableDictionary alloc] initWithDictionary:@{
        @"ifv" : [[UIDevice currentDevice] identifierForVendor].UUIDString,
        @"atts": [LoopMeIdentityProvider customAuthorizationStatus],
        @"plugin" : @([self parameterForBatteryState]),
        @"chargelevel" : [NSString stringWithFormat:
                          @"%f", [UIDevice currentDevice].batteryLevel],
        @"orientation" : [self parameterForOrientation],
        @"timezone" : [self parameterForTimeZone]}];
    
    if (![LoopMeIdentityProvider advertisingTrackingEnabled]){
        NSString *ifv = [[UIDevice currentDevice] identifierForVendor].UUIDString;
        [ext setObject:ifv forKey:@"ifv"];
    }
    
    if ([LoopMeGlobalSettings sharedInstance].liveDebugEnabled) {
        [ext setObject:[[LoopMeAudioCheck shared] currentOutputs] forKey:@"audio_outputs"]; //
        NSUInteger isAudioPlaying = [[LoopMeAudioCheck shared] isAudioPlaying] ? 1 : 0;
        [ext setObject:@(isAudioPlaying) forKey:@"music"];
    }
    
    if ([LoopMeIdentityProvider appTrackingTransparencyEnavled] && [ASIdentifierManager sharedManager].isAdvertisingTrackingEnabled) {
        NSString *idfa = [LoopMeIdentityProvider advertisingTrackingDeviceIdentifier];
        [ext setObject:idfa forKey:@"ifa"];
    }
    
    return ext;
}

- (NSDictionary *)impressionObject:(CGSize)size
                   integrationType:(NSString *)integrationType {
    
    NSMutableDictionary *impression = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *skadn = [[NSMutableDictionary alloc] init];
    
    impression[@"id"] = @1;
    impression[@"displaymanager"] = @"LOOPME_SDK";
    impression[@"displaymanagerver"] = [self sdkVersion];
    impression[@"instl"] = self.isInterstitial ? @1 : @0;
    impression[@"bidfloor"] = @0;
    impression[@"secure"] = @1;
    
    if (self.video) {
        impression[@"video"] = [self videoObject:size];
    }
    
    if (self.banner) {
        impression[@"banner"] = [self bannerObject:size];
    }
    
    if (!integrationType) {
        integrationType = @"normal";
    }
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSArray *skAdNetworkItems = infoDict[@"SKAdNetworkItems"];
    NSMutableArray *skAdIdentifiers = [NSMutableArray array];
    
    for (NSDictionary *dictionary in skAdNetworkItems) {
        NSString *skAdNetworkIdentifier = dictionary[@"SKAdNetworkIdentifier"];
        if (skAdNetworkIdentifier != nil) {
            [skAdIdentifiers addObject:skAdNetworkIdentifier];
        }
    }
    
    skadn[@"versions"] = @[@"2.0", @"2.1", @"2.2", @"3.0", @"4.0"];
    skadn[@"sourceapp"] = [self parameterForBundleIdentifier];
    skadn[@"skadnetids"] = skAdIdentifiers;
    impression[@"metric"] = [self parameterForAvailableTrackers];
    impression[@"ext"] = @{
        @"it" : integrationType,
        @"skadn": skadn};

    return impression;
}

- (NSDictionary *)videoObject:(CGSize)size {
    NSMutableDictionary *video = [[NSMutableDictionary alloc] init];
    
    video[@"mimes"] = @[@"video/mp4"];
    video[@"minduration"] = @5;
    video[@"maxduration"] = @999;
    video[@"protocols"] = @[@2, @3, @7, @8];
    video[@"startdelay"] = @0;
    video[@"linearity"] = @1;
    video[@"sequence"] = @1;
    video[@"battr"] = @[@3, @8];
    video[@"maxbitrate"] = @1024;
    video[@"boxingallowed"] = @1;
    video[@"delivery"] = @[@2];
    video[@"w"] = @(size.width);
    video[@"h"] = @(size.height);
    video[@"api"] = @[@2, @5, @7];
    video[@"skip"] = @1; // 0 - not, 1 - skippable
    
    return video;
}

- (NSDictionary *)bannerObject:(CGSize)size {
    NSMutableDictionary *banner = [[NSMutableDictionary alloc] init];
    
    banner[@"w"] = @(size.width);
    banner[@"h"] = @(size.height);
    banner[@"id"] = @1;
    banner[@"battr"] = @[@3, @8];
    banner[@"api"] = @[@2, @5, @7];
    banner[@"expdir"] = @[@5];
    
    return banner;
}

- (LoopMeDeviceCharge)parameterForBatteryState {
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

- (NSString *)parameterForTimeZone {
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

- (NSString *)parameterForOrientation {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    return UIInterfaceOrientationIsPortrait(orientation) ?
    kLoopMeInterfaceOrientationPortrait :
    kLoopMeInterfaceOrientationLandscape;
}

- (NSInteger)parameterForConnectionType {
    return [[LoopMeReachability reachabilityForLocalWiFi] connectionType];
}

- (NSString *)parameterForBundleIdentifier {
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    return bundleIdentifier ? [bundleIdentifier lm_stringByAddingPercentEncodingForRFC3986] : @"";
}

- (NSString *)parameterForDNT {
    return ([LoopMeIdentityProvider advertisingTrackingEnabled] ? @"0" : @"1");
}

- (NSString *)parameterForWiFiName {
    return [[LoopMeReachability reachabilityForLocalWiFi] getSSID];
}

- (NSString *)parameterForLanguage {
    return [NSLocale preferredLanguages][0];
}

- (NSString *)userAgent {
    return [UserAgent defaultUserAgent];
}

- (NSArray *)parameterForAvailableTrackers {
    NSArray *vendors = [self viewabilityVendors];
    NSMutableArray *parameter = [[NSMutableArray alloc] init];
    for (NSString *vendor in vendors) {
        [parameter addObject:@{@"type" : @"viewability", @"vendor" : vendor}];
    }
    return parameter;
}

- (NSArray *)viewabilityVendors {
    return @[@"moat", @"ias"];
}

- (NSString *)sdkVersion {
    NSString *bundleVersion = [[NSBundle bundleForClass:LoopMeORTBTools.class].infoDictionary objectForKey:@"CFBundleShortVersionString"];
    return bundleVersion;
}

@end
