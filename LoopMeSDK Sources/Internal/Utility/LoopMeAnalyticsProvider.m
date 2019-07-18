//
//  AnalyticsProvider.m
//  LoopMeSDK
//
//  Created by Bohdan on 2/29/16.
//  Copyright © 2016 LoopMe. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "LoopMeAnalyticsProvider.h"
#import "LoopMeLogging.h"
#import "LoopMeServerURLBuilder.h"
#import "LoopMeIdentityProvider.h"

static NSString * const kLoopMeBackgroundAnalyticSessionID = @"com.loopme.backgrouns.session";
static NSTimeInterval const kLoopMeAnalyticsSendInterval = 900;

@interface LoopMeAnalyticsProvider ()

@property (nonatomic, strong) NSTimer *senderTimer;
@property (nonatomic, strong) NSURL *sendURL;
@property (nonatomic, strong) NSString *userAgent;
@property (nonatomic, strong) NSURLSession *session;

@end

@implementation LoopMeAnalyticsProvider

+ (instancetype)sharedInstance {
    static LoopMeAnalyticsProvider *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LoopMeAnalyticsProvider alloc] init];
    });
    return instance;
}

- (void)dealloc {
    [_senderTimer invalidate];
    _senderTimer = nil;
}

- (instancetype)init {
    if (self = [super init]) {
        _analyticURLString = @"https://tk0x1.com/api/v2/events";
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:kLoopMeBackgroundAnalyticSessionID];
        self.session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:nil];
        
        __block UIBackgroundTaskIdentifier bgTask = 0;
        UIApplication  *app = [UIApplication sharedApplication];
        bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
            [app endBackgroundTask:bgTask];
        }];
        
        [self sendData];
        
        _senderTimer = [NSTimer
                 scheduledTimerWithTimeInterval:kLoopMeAnalyticsSendInterval
                 target:self
                 selector:@selector(sendData)
                 userInfo:nil
                 repeats:YES];
    }
    
    return self;
}

- (NSString *)userAgent {
    if (_userAgent == nil) {
        __weak LoopMeAnalyticsProvider *weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.userAgent = [[[UIWebView alloc] init] stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        });
    }
    return _userAgent;
}

- (void)sendData {
    self.sendURL = [NSURL URLWithString:[_analyticURLString stringByAppendingString:[NSString stringWithFormat:@"?et=INFO&vt=%@", [LoopMeIdentityProvider advertisingTrackingDeviceIdentifier]]]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.sendURL
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:60.0];
    
    
    [request setHTTPMethod:@"POST"];
    [request setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
    
    NSString *params = [LoopMeServerURLBuilder packageIDs];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[self.session dataTaskWithRequest:request] resume];
    });
}

@end
