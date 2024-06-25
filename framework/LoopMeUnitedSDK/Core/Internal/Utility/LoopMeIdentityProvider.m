//
//  LoopMeIdentityProvider.m
//  LoopMeSDK
//
//  Created by Dmitriy Lihachov on 11/11/13.
//  Copyright (c) 2013 LoopMe. All rights reserved.
//

#import <AdSupport/AdSupport.h>
#import <UIKit/UIKit.h>
#import <sys/utsname.h>

#import "NSString+Encryption.h"
#import "LoopMeIdentityProvider.h"
#import "LoopMeLogging.h"
#import <AdSupport/ASIdentifierManager.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSUInteger, LoopMeORTBDeviceType) {
    LoopMeORTBDeviceTypePhone = 4,
    LoopMeORTBDeviceTypeTablet = 5,
};

typedef NS_ENUM(NSInteger, CustomAuthorizationStatus) {
    CustomAuthorizationStatusNotDetermined = 0,
    CustomAuthorizationStatusRestricted = 1 ,
    CustomAuthorizationStatusDenied = 2,
    CustomAuthorizationStatusAuthorized = 3
};

@implementation LoopMeIdentityProvider

#pragma mark - Class Methods

+ (NSString *)advertisingTrackingDeviceIdentifier {
    NSString *identifier = nil;
    identifier = [ASIdentifierManager sharedManager].advertisingIdentifier.UUIDString;
    return [identifier uppercaseString];
}

+ (BOOL)advertisingTrackingEnabled {
    return [[self customAuthorizationStatus] integerValue] == CustomAuthorizationStatusAuthorized;
}

+ (BOOL) appTrackingTransparencyEnabled {
    if (@available(iOS 14, *)) {
        ATTrackingManagerAuthorizationStatus trackingStatus = [ATTrackingManager trackingAuthorizationStatus];
        return trackingStatus == ATTrackingManagerAuthorizationStatusAuthorized;
    }
    // Prior to iOS 14, IDFA is available without explicit user permission
    return YES;
}

+ (NSString *)deviceType {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return @"phone";
    } else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return @"tablet";
    }
    
    return nil;
}

+ (NSUInteger)deviceTypeNum {
    NSString *deviceType = [self deviceType];
    
    return [deviceType isEqualToString:@"phone"] ? LoopMeORTBDeviceTypePhone : LoopMeORTBDeviceTypeTablet;
}

+ (NSString *) deviceOS {
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString *)deviceManufacturer {
    return @"Apple";
}

+ (NSString *)deviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *currentModel = [NSString stringWithCString:systemInfo.machine
                                         encoding:NSUTF8StringEncoding];
    
    return currentModel;
}

+ (NSString *)deviceAppleModel {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return @"iphone";
    } else if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        return @"ipad";
    }
    return nil;
}

+ (NSString *)phoneName {
    return [[[UIDevice currentDevice] name] lm_AES128Encrypt];
}

+ (NSNumber *)customAuthorizationStatus {
    if (@available(iOS 14, *)) {
        ATTrackingManagerAuthorizationStatus status = [ATTrackingManager trackingAuthorizationStatus];
        
        switch (status) {
            case kCLAuthorizationStatusNotDetermined:
                return @(CustomAuthorizationStatusNotDetermined);
            case kCLAuthorizationStatusRestricted:
                return  @(CustomAuthorizationStatusRestricted);
            case kCLAuthorizationStatusDenied:
                return @(CustomAuthorizationStatusDenied);
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                return @(CustomAuthorizationStatusAuthorized);
            default:
                return @(CustomAuthorizationStatusNotDetermined);
        }
    } else {
        return @(CustomAuthorizationStatusNotDetermined);
    }
}

@end
