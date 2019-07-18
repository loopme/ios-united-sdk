//
//  LoopMeVPAIDClient.m
//  LoopMeSDK
//
//  Copyright (c) 2016 LoopMe. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <WebKit/WebKit.h>

#import "LoopMeAdWebView.h"
#import "LoopMeVPAIDClient.h"
#import "LoopMeVPAIDVideoClient.h"
#import "LoopMeLogging.h"
#import "NSDictionary+JSONPrint.h"

const struct LoopMeVPAIDViewModeStruct LoopMeVPAIDViewMode = {
    .normal = @"normal",
    .thumbnail = @"thumbnail",
    .fullscreen = @"thumbnail"
};


@interface LoopMeVPAIDClient ()

@property (nonatomic, weak) id<LoopMeVpaidProtocol> delegate;
@property (nonatomic, weak, readonly) WKWebView *webViewClient;
@property (nonatomic, strong) NSTimer *actionTimeOutTimer;

@end

@implementation LoopMeVPAIDClient

#pragma mark - Life Cycle

- (void)dealloc {
    [self stopActionTimeOutTimer];
}

- (instancetype)initWithDelegate:(id<LoopMeVpaidProtocol>)deleagate webView:(WKWebView *)webView {
    if (self = [super init]) {
        _delegate = deleagate;
        _webViewClient = webView;
    }
    return self;
}

#pragma mark - Public

- (double)handshakeVersion {
//    JSValue *version = [self.vpaidWrapper invokeMethod:@"handshakeVersion" withArguments:@[@"2.0"]];
    return 2;// [version toDouble];
}

- (void)initAdWithWidth:(int)width height:(int)height viewMode:(NSString *)viewMode desiredBitrate:(double)desiredBitrate creativeData:(NSDictionary *)creativeData {
    
    [self invokeVpaidMethod:@"initAd" withArguments:[NSArray arrayWithObjects:@(width), @(height), viewMode, @(desiredBitrate), creativeData, nil]];
}

- (void)resizeAdWithWidth:(int)width height:(int)height viewMode:(NSString *)viewMode {
    [self invokeVpaidMethod:@"resizeAd" withArguments:[NSArray arrayWithObjects:@(width), @(height), viewMode, nil]];
}

- (void)startAd {
    [self invokeVpaidMethod:@"startAd" withArguments:nil];
}

- (void)stopAd {
    [self invokeVpaidMethod:@"stopAd" withArguments:nil];
}

- (void)pauseAd {
    [self invokeVpaidMethod:@"pauseAd" withArguments:nil];
}

- (void)resumeAd {
    [self invokeVpaidMethod:@"resumeAd" withArguments:nil];
}

- (void)expandAd {
    [self invokeVpaidMethod:@"expandAd" withArguments:nil];
}

- (void)collapseAd {
    [self invokeVpaidMethod:@"collapseAd" withArguments:nil];
}

- (void)skipAd {
    [self invokeVpaidMethod:@"skipAd" withArguments:nil];
}

- (void)setAdVolume:(double)volume {
    [self invokeVpaidMethod:@"setAdVolume" withArguments:@[@(volume)]];
}

- (void)stopActionTimeOutTimer {
    [self.actionTimeOutTimer invalidate];
    self.actionTimeOutTimer = nil;
}

#pragma mark - private


- (void)invokeVpaidMethod:(NSString *)method withArguments:(NSArray *)arguments {
    NSMutableString *stringParams = [NSMutableString new];
    if (arguments.count) {
        for (id param in arguments) {
            NSString *formatedParam;
            if ([param isKindOfClass:[NSString class]]) {
                if ([param isEqualToString:@"true"] || [param isEqualToString:@"false"]) {
                    formatedParam = [NSString stringWithFormat:@"%@,", param];
                } else {
                    formatedParam = [NSString stringWithFormat:@"'%@',", param];
                }
                
            } else if ([param isKindOfClass:[NSNumber class]]) {
                formatedParam = [NSString stringWithFormat:@"%ld,", (long)[param integerValue]];
            } else if([param isKindOfClass:[NSDictionary class]]) {
                formatedParam = [NSString stringWithFormat:@"%@,", [param lm_jsonStringWithPrettyPrint:NO]];
            }
            [stringParams appendString:formatedParam];
        }
        //remove last ','
        stringParams = [[stringParams substringToIndex:[stringParams length] - 1] mutableCopy];
    }
    
    NSString *eventString = [NSString stringWithFormat:@"getVPAIDWrapper().%@(%@)", method, stringParams];
    
    [self.webViewClient evaluateJavaScript:eventString completionHandler:nil];
}

- (void)actionTimeOut:(NSTimer *)timer {
    NSString *action = [timer userInfo];
    if ([action isEqualToString:@"initAd"] || [action isEqualToString:@"stoptAd"]) {
        [self.delegate vpaidJSError:[NSString stringWithFormat:@"%@ timeout", action]];
    } else if ([action isEqualToString:@"startAd"]) {
        [self stopAd];
    } else {
        [self.delegate vpaidAdStopped];
    }
}

@end
