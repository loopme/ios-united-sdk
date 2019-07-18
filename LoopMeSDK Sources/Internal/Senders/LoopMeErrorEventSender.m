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

@implementation LoopMeErrorEventSender

+ (void)sendError:(LoopMeEventErrorType)errorType
     errorMessage:(NSString * _Nonnull)errorMessage appkey:(NSString * _Nonnull)appkey {
    
    NSString *errorTypeParameter;
    switch (errorType) {
        case LoopMeEventErrorTypeJS:
            errorTypeParameter = @"js";
            break;
            
        case LoopMeEventErrorTypeBadAsset:
            errorTypeParameter = @"bad_asset";
            break;
            
        case LoopMeEventErrorTypeServer:
            errorTypeParameter = @"server";
            break;
            
        case LoopMeEventErrorTypeCustom:
            errorTypeParameter = @"custom";
            break;
            
        default:
            break;
    }
    
    NSURL *url = [NSURL URLWithString:@"https://tk0x1.com/api/errors"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    
    NSString *params = [NSString stringWithFormat:@"device_os=ios&sdk_type=loopme&sdk_version=%@&device_id=%@&package=%@&msg=sdk_error&error_type=%@&error_msg=\"%@\"&app_key=%@", LOOPME_SDK_VERSION, [LoopMeIdentityProvider advertisingTrackingDeviceIdentifier], [NSBundle mainBundle].bundleIdentifier, errorTypeParameter, errorMessage, appkey];

    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask *postDataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request];
    
    [postDataTask resume];
}

@end
