//
//  LoopMeVPAIDClient.m
//  LoopMeSDK
//
//  Copyright (c) 2016 LoopMe. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

#import "LoopMeAdWebView.h"
#import "LoopMeVPAIDClient.h"
#import "LoopMeVPAIDVideoClient.h"
#import "LoopMeLogging.h"

static const NSTimeInterval kLoopMeVPAIDActionTimeOut = 5;

const struct LoopMeVPAIDViewModeStruct LoopMeVPAIDViewMode = {
    .normal = @"normal",
    .thumbnail = @"thumbnail",
    .fullscreen = @"thumbnail"
};


@interface LoopMeVPAIDClient ()

@property (nonatomic, weak) id<LoopMeVpaidProtocol> delegate;
@property (nonatomic, strong) JSContext *jsContext;
@property (nonatomic, strong) JSValue *vpaidWrapper;
@property (nonatomic, strong) NSTimer *actionTimeOutTimer;

@end

@implementation LoopMeVPAIDClient

#pragma mark - Life Cycle

- (void)dealloc {
    [self stopActionTimeOutTimer];
}

- (instancetype)initWithDelegate:(id<LoopMeVpaidProtocol>)deleagate jsContext:(JSContext *)context {
    if (self = [super init]) {
        _delegate = deleagate;

        _jsContext = context;
        
        id log = ^(JSValue *msg) {
             NSLog(@"JS: %@", msg);
        };
        
        _jsContext[@"console"][@"log"] = log;
        _jsContext[@"console"][@"info"] = log;
        _jsContext[@"console"][@"debug"] = log;
        _jsContext[@"console"][@"error"] = log;
        
        __weak LoopMeVPAIDClient *safeSelf = self;
        [_jsContext setExceptionHandler:^(JSContext *context, JSValue *value) {
            LoopMeLogDebug(@"JS exception: %@", [value toString]);
            [safeSelf.delegate vpaidJSError:[value toString]];
        }];
        
        JSValue *getVPAIDWrapperFunc = _jsContext[@"getVPAIDWrapper"];
        _vpaidWrapper = [getVPAIDWrapperFunc callWithArguments:nil];
        [_vpaidWrapper invokeMethod:@"setVpaidClient" withArguments:@[_delegate]];
    }
    return self;
}

#pragma mark - Public

- (double)handshakeVersion {
    JSValue *version = [self.vpaidWrapper invokeMethod:@"handshakeVersion" withArguments:@[@"2.0"]];
    return [version toDouble];
}

- (void)initAdWithWidth:(int)width height:(int)height viewMode:(NSString *)viewMode desiredBitrate:(double)desiredBitrate creativeData:(NSDictionary *)creativeData environmentVars:(NSDictionary *)environmentVars {
    
    [self invokeVpaidMethod:@"initAd" withArguments:[NSArray arrayWithObjects:@(width), @(height), viewMode, @(desiredBitrate), creativeData, environmentVars, nil]];
}

- (void)resizeAdWithWidth:(int)width height:(int)height viewMode:(NSString *)viewMode {
    [self.vpaidWrapper invokeMethod:@"resizeAd" withArguments:[NSArray arrayWithObjects:@(width), @(height), viewMode, nil]];
}

- (void)startAd {
    [self invokeVpaidMethod:@"startAd" withArguments:nil];
}

- (void)stopAd {
    [self invokeVpaidMethod:@"stopAd" withArguments:nil];
}

- (void)pauseAd {
    [self.vpaidWrapper invokeMethod:@"pauseAd" withArguments:nil];
}

- (void)resumeAd {
    [self.vpaidWrapper invokeMethod:@"resumeAd" withArguments:nil];
}

- (void)expandAd {
    [self.vpaidWrapper invokeMethod:@"expandAd" withArguments:nil];
}

- (void)collapseAd {
    [self.vpaidWrapper invokeMethod:@"collapseAd" withArguments:nil];
}

- (void)skipAd {
    [self.vpaidWrapper invokeMethod:@"skipAd" withArguments:nil];
}

- (BOOL)getAdExpanded {
    return [[self.vpaidWrapper invokeMethod:@"getAdExpanded" withArguments:nil] toBool];
}

- (BOOL)getAdSkippableState {
    return [[self.vpaidWrapper invokeMethod:@"getAdSkippableState" withArguments:nil] toBool];
}

- (BOOL)getAdLinear {
    return [[self.vpaidWrapper invokeMethod:@"getAdLinear" withArguments:nil] toBool];
}

- (NSInteger)getAdWidth {
    return [[self.vpaidWrapper invokeMethod:@"getAdWidth" withArguments:nil] toInt32];
}

- (NSInteger)getAdHeight {
    return [[self.vpaidWrapper invokeMethod:@"getAdHeight" withArguments:nil] toInt32];
}

- (NSInteger)getAdRemainingTime {
    return [[self.vpaidWrapper invokeMethod:@"getAdRemainingTime" withArguments:nil] toInt32];
}

- (NSInteger)getAdDuration {
    return [[self.vpaidWrapper invokeMethod:@"getAdDuration" withArguments:nil] toInt32];
}

- (double)getAdVolume {
    return [[self.vpaidWrapper invokeMethod:@"getAdVolume" withArguments:nil] toDouble];
}

- (void)setAdVolume:(double)volume {
    [self.vpaidWrapper invokeMethod:@"setAdVolume" withArguments:@[@(volume)]];
}

- (NSString *)getAdCompanions {
    return [[self.vpaidWrapper invokeMethod:@"getAdCompanions" withArguments:nil] toString];
}

- (BOOL)getAdIcons {
    return [[self.vpaidWrapper invokeMethod:@"getAdIcons" withArguments:nil] toBool];
}

- (void)stopActionTimeOutTimer {
    [self.actionTimeOutTimer invalidate];
    self.actionTimeOutTimer = nil;
}
#pragma mark - private

- (JSValue *)invokeVpaidMethod:(NSString *)method withArguments:(NSArray *)arguments {
    self.actionTimeOutTimer = [NSTimer scheduledTimerWithTimeInterval:kLoopMeVPAIDActionTimeOut target:self selector:@selector(actionTimeOut:) userInfo:method repeats:NO];
    return [self.vpaidWrapper invokeMethod:method withArguments:arguments];
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
