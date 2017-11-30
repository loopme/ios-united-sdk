//
//  LoopMeErrorSender.m
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
     errorMessage:(NSString *)errorMessage appkey:(NSString *)appkey {
    
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
    
    NSURL *url = [NSURL URLWithString:@"https://track.loopme.me/api/errors"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    
    NSString *params = [NSString stringWithFormat:@"device_os=ios&sdk_type=loopme&sdk_version=%@&device_id=%@&package=%@&app_key=%@&msg=sdk_error&error_type=%@&error_msg=\"%@\"", LOOPME_SDK_VERSION, [LoopMeIdentityProvider advertisingTrackingDeviceIdentifier], [NSBundle mainBundle].bundleIdentifier, appkey, errorTypeParameter, errorMessage];

    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask *postDataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request];
    
    [postDataTask resume];
}

@end
