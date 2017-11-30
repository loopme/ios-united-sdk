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

//typedef enum : NSUInteger {
//    Phone = 4,
//    Tablet = 5
//} LoopMeORTBDeviceType;

typedef NS_ENUM(NSUInteger, LoopMeORTBDeviceType) {
    LoopMeORTBDeviceTypePhone = 4,
    LoopMeORTBDeviceTypeTablet = 5,
};
@implementation LoopMeIdentityProvider

#pragma mark - Class Methods

+ (NSString *)advertisingTrackingDeviceIdentifier {
    NSString *identifier = nil;
    identifier = [ASIdentifierManager sharedManager].advertisingIdentifier.UUIDString;
    if (![ASIdentifierManager sharedManager].isAdvertisingTrackingEnabled) {
        identifier = @"00000000-0000-0000-0000-000000000000";
    }
    return [identifier uppercaseString];
}

+ (BOOL)advertisingTrackingEnabled {
    BOOL enabled = YES;

    if ([self deviceHasAdvertisingIdentifier]) {
        enabled = [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
    }

    return enabled;
}

+ (BOOL)deviceHasAdvertisingIdentifier {
    return !!NSClassFromString(@"ASIdentifierManager");
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

+ (NSString *)deviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *currentModel = [NSString stringWithCString:systemInfo.machine
                                         encoding:NSUTF8StringEncoding];
    
    return currentModel;
}

+ (NSString *)phoneName {
    return [[[UIDevice currentDevice] name] lm_AES128Encrypt];
}

@end
