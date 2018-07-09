//
//  LoopMeGDPRAPIService.m
//  LoopMeSDK
//
//  Created by Bohdan on 4/27/18.
//  Copyright © 2018 LoopMe. All rights reserved.
//

#import "LoopMeGDPRAPIService.h"
#import "LoopMeGDPRTools.h"

static NSString * const kLoopMeUserConsentAPILink = @"https://gdpr.loopme.com/consent_check?device_id=%@";
static int const _kLoopMeUserConsentTimeout = 3;

static NSString * const kLoopMeNeedConsentKey = @"need_consent";
static NSString * const kLoopMeUserConsentKey = @"user_consent";
static NSString * const kLoopMeConsentURLKey = @"consent_url";

static NSDictionary *cacheResponse;

static dispatch_semaphore_t notified;
static dispatch_group_t group;
static dispatch_queue_t queue;

@implementation LoopMeGDPRAPIService

+ (NSDictionary *)apiResponse:(NSString *)deviceID ignoreCache:(BOOL)ignoreCache {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        notified = dispatch_semaphore_create(0);
        group = dispatch_group_create();
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    });
    
    if (cacheResponse && !ignoreCache) {
        return cacheResponse;
    } else {
        cacheResponse = nil;
    }
    
    dispatch_group_async(group, queue, ^{
        NSString *apiLinkString = [NSString stringWithFormat:kLoopMeUserConsentAPILink, deviceID];
        NSURL *apiLink = [NSURL URLWithString:apiLinkString];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.timeoutIntervalForRequest = _kLoopMeUserConsentTimeout;
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        
        [[session dataTaskWithURL:apiLink completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSDictionary *responseDict;
            if (data) {
                responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            }
            cacheResponse = responseDict;
            
            dispatch_group_notify(group, queue, ^{
                dispatch_semaphore_signal(notified);
            });
        }] resume];
    });
    
    // Block this thread until all tasks are complete
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    // Wait until the notify block signals our semaphore
    dispatch_semaphore_wait(notified, DISPATCH_TIME_FOREVER);
    
    return cacheResponse;
}

+ (NSURL *)consentURL:(NSString *)deviceID {
    NSDictionary *resultDict = [self apiResponse:deviceID ignoreCache:NO];
    
    if ([resultDict objectForKey:kLoopMeConsentURLKey]) {
        NSString *urlString = [NSString stringWithFormat:@"%@?is_sdk=true&device_id=%@", [resultDict objectForKey:kLoopMeConsentURLKey], deviceID];
        
        urlString = [NSString stringWithFormat:@"%@?is_sdk=true&device_id=%@", @"https://i.loopme.me/html/gdpr_page/gdpr_page.html", deviceID];
        
        return [NSURL URLWithString:urlString];
    }
    
    return nil;
}

+ (BOOL)isNeedUserConsent:(NSString *)deviceID {
    NSDictionary *resultDict = [self apiResponse:deviceID ignoreCache:YES];

    if ([resultDict objectForKey:kLoopMeNeedConsentKey]) {
        return [[resultDict objectForKey:kLoopMeNeedConsentKey] boolValue];
    }
    
    return NO;
}

+ (BOOL)userConsent:(NSString *)deviceID consentType:(LoopMeConsentType *)consentType {
    NSDictionary *resultDict = [self apiResponse:deviceID ignoreCache:NO];
    
    LoopMeConsentType tempConsentType;
    //check in cache response
    BOOL userConsent = [self checkConsentIn:resultDict consentType:&tempConsentType];
    
    if (tempConsentType == LoopMeConsentTypeFailedAPI) {
        //chack again without cache
        resultDict = [self apiResponse:deviceID ignoreCache:YES];
        userConsent = [self checkConsentIn:resultDict consentType:&tempConsentType];
    }
    
    *consentType = tempConsentType;
    return userConsent;
}

+ (BOOL)checkConsentIn:(NSDictionary *)dict consentType:(LoopMeConsentType *)consentType {
    if ([dict objectForKey:kLoopMeUserConsentKey]) {
        *consentType = LoopMeConsentTypeLoopMe;
        return [[dict objectForKey:kLoopMeUserConsentKey] boolValue];
    } else {
        *consentType = LoopMeConsentTypeFailedAPI;
        return NO;
    }
}

@end
