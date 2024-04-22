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
    }
    cacheResponse = nil;
    
    dispatch_group_async(group, queue, ^{
        NSString *apiLinkString = [NSString stringWithFormat: kLoopMeUserConsentAPILink, deviceID];
        NSURL *apiLink = [NSURL URLWithString: apiLinkString];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.timeoutIntervalForRequest = _kLoopMeUserConsentTimeout;
        NSURLSession *session = [NSURLSession sessionWithConfiguration: configuration];
        
        [[session dataTaskWithURL: apiLink
                completionHandler: ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data) {
                cacheResponse = [NSJSONSerialization JSONObjectWithData: data options: 0 error: &error];
            }
            
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

@end
