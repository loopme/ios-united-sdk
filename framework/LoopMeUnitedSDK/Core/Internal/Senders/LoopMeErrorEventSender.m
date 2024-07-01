//
//  LoopMeErrorSender.m
//  LoopMeSDK
//
//  Created by Bohdan on 12/11/15.
//  Copyright © 2015 LoopMe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoopMeErrorEventSender.h"
#import "LoopMeDefinitions.h"
#import "LoopMeGlobalSettings.h"
#import "LoopMeIdentityProvider.h"
#import "LoopMeSDK.h"
#import "LoopMeUnitedSDK/LoopMeUnitedSDK-Swift.h"

@implementation LoopMeErrorEventSender

+ (NSString *)errorTypeToString: (LoopMeEventErrorType)errorType {
    switch (errorType) {
        case LoopMeEventErrorTypeJS: return @"js";
        case LoopMeEventErrorTypeBadAsset: return @"bad_asset";
        case LoopMeEventErrorTypeServer: return @"server";
        case LoopMeEventErrorTypeCustom: return @"custom";
    }
    return @"unknown";
}

+ (void)sendError: (LoopMeEventErrorType)errorType
       errorMessage: (NSString * _Nonnull)errorMessage
             appkey: (NSString * _Nonnull)appkey{
    return [self sendError:errorType errorMessage:errorMessage info: @{@"app_key" : appkey }];
}

+ (void)sendError:(LoopMeEventErrorType)errorType
     errorMessage:(NSString * _Nonnull)errorMessage
             info:(NSDictionary<NSString *, NSString *>  * _Nonnull)info {
    NSURLComponents *components = [[NSURLComponents alloc] init];
    
    components.queryItems = @[
        [NSURLQueryItem queryItemWithName: @"device_os"           value: @"ios"],
        [NSURLQueryItem queryItemWithName: @"device_id"           value: [LoopMeIdentityProvider advertisingTrackingDeviceIdentifier]],
        [NSURLQueryItem queryItemWithName: @"device_model"        value: [LoopMeIdentityProvider deviceAppleModel]],
        [NSURLQueryItem queryItemWithName: @"device_os_ver"       value: [LoopMeIdentityProvider deviceOS]],
        [NSURLQueryItem queryItemWithName: @"device_manufacturer" value: [LoopMeIdentityProvider deviceManufacturer]],
        [NSURLQueryItem queryItemWithName: @"sdk_type"            value: @"loopme"],
        [NSURLQueryItem queryItemWithName: @"msg"                 value: @"sdk_error"],
        [NSURLQueryItem queryItemWithName: @"sdk_version"         value: LOOPME_SDK_VERSION],
        [NSURLQueryItem queryItemWithName: @"package"             value: [NSBundle mainBundle].bundleIdentifier],
        [NSURLQueryItem queryItemWithName: @"error_type"          value: [LoopMeErrorEventSender errorTypeToString: errorType]],
        [NSURLQueryItem queryItemWithName: @"error_msg"           value: [NSString stringWithFormat: @"\"%@\"", errorMessage]],
        [NSURLQueryItem queryItemWithName: @"ifv"                 value: [UIDevice currentDevice].identifierForVendor.UUIDString],
        ];
    
    NSMutableArray *queryItems = [[NSMutableArray alloc] initWithArray:components.queryItems];

    for (NSString * key in [info allKeys]) {
        [queryItems addObject: [[NSURLQueryItem alloc] initWithName:key value:info[key]]];;
    }
    
    components.queryItems = queryItems;
    
    NSURL *url = [NSURL URLWithString: @"https://tk0x1.com/api/errors"];
    NSMutableURLRequest *request = [
        NSMutableURLRequest requestWithURL: url cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 60.0
    ];
    [request setHTTPMethod: @"POST"];
    [request setValue: @"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
    [request setHTTPBody: [components.query dataUsingEncoding: NSUTF8StringEncoding]];
    [[[NSURLSession sharedSession] dataTaskWithRequest: request] resume];
}

@end
