//
//  LoopMeJSClient.m
//  LoopMeSDK
//
//  Created by Dmitriy on 10/24/14.
//
//

#import <AVFoundation/AVFoundation.h>
#import <WebKit/WebKit.h>

#import "LoopMeAdWebView.h"
#import "LoopMeDefinitions.h"
#import "LoopMeJSClient.h"
#import "LoopMeVideoCommunicatorProtocol.h"
#import "NSURL+LoopMeAdditions.h"
#import "LoopMeLogging.h"
#import "NSURL+LoopMeAdditions.h"

/// Commands
const struct LoopMeJSCommandsStruct LoopMeJSCommands = {
    .success = @"success",
    .fail = @"fail",
    .close = @"close",
    .play = @"play",
    .pause = @"pause",
    .mute = @"mute",
    .load = @"load",
    .vibrate = @"vibrate",
    .enableStretching = @"enableStretching",
    .disableStretching = @"disableStretching",
    .fullscreenMode = @"fullscreenMode"
};

typedef NS_ENUM(NSUInteger, LoopMeJSParamType) {
    LoopMeJSParamTypeNumber,
    LoopMeJSParamTypeString,
    LoopMeJSParamTypeBoolean
};

// Events
const struct LoopMeEventStruct LoopMeEvent = {
    .isVisible = @"isVisible",
    .state = @"state",
    .duration = @"duration",
    .currentTime = @"currentTime",
    .shake = @"shake",
    .fullscreenMode = @"fullscreenMode"
};

const struct LoopMeWebViewStateStruct LoopMeWebViewState = {
    .visible = @"VISIBLE",
    .hidden = @"HIDDEN",
    .closed = @"CLOSED"
};

@interface LoopMeJSClient ()

@property (nonatomic, weak) id<LoopMeJSClientDelegate> delegate;
@property (nonatomic, weak, readonly) id<LoopMeVideoCommunicatorProtocol> videoClient;
@property (nonatomic, weak, readonly) WKWebView *webViewClient;

- (void)loadVideoWithParams: (NSDictionary *)params;
- (void)playVideoWithParams: (NSDictionary *)params;
- (void)pauseVideoWithParams: (NSDictionary *)params;
@end

@implementation LoopMeJSClient

#pragma mark - Life Cycle

- (void)dealloc {
    
}

- (instancetype)initWithDelegate: (id<LoopMeJSClientDelegate>)deleagate {
    if (self = [super init]) {
        _delegate = deleagate;
    }
    return self;
}

#pragma mark - Properties

- (id<LoopMeVideoCommunicatorProtocol>)videoClient {
    return [self.delegate videoCommunicator];
}

- (WKWebView *)webViewClient {
    return [self.delegate webViewTransport];
}

#pragma mark - Private

- (void)loadVideoWithParams: (NSDictionary *)params {
    [self.videoClient loadWithURL: [NSURL lm_urlWithEncodedString: params[@"src"]]];
}

- (void)playVideoWithParams: (NSDictionary *)params {
    NSString *time = params[@"currentTime"];
    [self.videoClient playFromTime: time ? [time doubleValue] : -1];
}

- (void)pauseVideoWithParams: (NSDictionary *)params {
    NSString *time = params[@"currentTime"];
    [self.videoClient pauseOnTime: time ? [time doubleValue] : -1];
}

- (void)muteVideoWithParams: (NSDictionary *)params {
    [self.videoClient setMute: [params[@"mute"] isEqual: @"true"]];
}

#pragma mark JS Commands

- (void)processCommand: (NSString *)command
          forNamespace: (NSString *)ns
            withParams: (NSDictionary *)params {
    LoopMeLogDebug(@"Processing JS command: %@, namespace: %@, params: %@", command, ns, params);

    if ([@[kLoopMeNamespaceWebview, kLoopMeNamespaceVideo] containsObject: ns]) {
        [self processJSCommand: command withParams: params namespace: ns];
    } else {
        LoopMeLogDebug(@"Namespace: %@ is not supported", ns);
    }
}

- (void)processJSCommand: (NSString *)command
              withParams: (NSDictionary *)params
               namespace: (NSString *)namespace {
    void (^selectedCase)(void) = @{
        LoopMeJSCommands.success: ^{
            [self.delegate JSClientDidReceiveSuccessCommand: self];
        },
        LoopMeJSCommands.fail: ^{
            [self.delegate JSClientDidReceiveFailCommand: self];
        },
        LoopMeJSCommands.close: ^{
            [self.delegate JSClientDidReceiveCloseCommand: self];
        },
        LoopMeJSCommands.vibrate: ^{
            [self.delegate JSClientDidReceiveVibrateCommand: self];
        },
        LoopMeJSCommands.fullscreenMode: ^{
            [self.delegate JSClientDidReceiveFulLScreenCommand: self fullScreen: [params[@"mode"] boolValue]];
        },
        // video protocol
        LoopMeJSCommands.load: ^{
            [self loadVideoWithParams: params];
        },
        LoopMeJSCommands.play: ^{
            [self playVideoWithParams: params];
        },
        LoopMeJSCommands.pause: ^{
            [self pauseVideoWithParams: params];
        },
        LoopMeJSCommands.mute: ^{
            [self muteVideoWithParams: params];
        },
        LoopMeJSCommands.enableStretching: ^{
            [self.videoClient setGravity: AVLayerVideoGravityResize];
        },
        LoopMeJSCommands.disableStretching: ^{
            [self.videoClient setGravity: AVLayerVideoGravityResizeAspect];
        },
    }[command];

    if (selectedCase != nil) {
        selectedCase();
    } else {
        LoopMeLogDebug(@"JS command: %@ for namespace: %@ is not supported", command, namespace);
    }
}

#pragma mark - Public

- (void)executeEvent: (NSString *)event
        forNamespace: (NSString *)ns
               param: (NSObject *)param {
    [self executeEvent: event
          forNamespace: ns
                 param: param
             paramBOOL: NO];
}

- (void)executeEvent: (NSString *)event
        forNamespace: (NSString *)ns
               param: (NSObject *)param
           paramBOOL: (BOOL)isBOOL {
    if (isBOOL) {
        param = [(NSNumber *)param boolValue] ? @"true" : @"false";
    } else if ([param isKindOfClass: [NSString class]]) {
        param = [NSString stringWithFormat:@"\"%@\"", param];
    }
    NSString *bridgeSetFormat = @"L.bridge.set(\"%@\",{%@:%@})";
    [self.webViewClient evaluateJavaScript: [NSString stringWithFormat: bridgeSetFormat, ns, event, param]
                         completionHandler: nil];
}

- (BOOL)shouldInterceptURL:(NSURL *)URL {
    return [URL.scheme.lowercaseString isEqualToString: @"loopme"];
}

- (void)processURL: (NSURL *)URL {
    [self processCommand: URL.lastPathComponent
            forNamespace: URL.host
              withParams: [URL lm_toDictionary]];
}

#pragma mark - LoopMeJSTransportProtocol

- (void)setVideoState: (NSString *)state {
    [self executeEvent: LoopMeEvent.state
          forNamespace: kLoopMeNamespaceVideo
                 param: state];
}

- (void)setWebViewState: (NSString *)state {
    [self executeEvent: LoopMeEvent.state
          forNamespace: kLoopMeNamespaceWebview
                 param: state];
}

- (void)setDuration: (CGFloat)fullDuration {
    [self executeEvent: LoopMeEvent.duration
          forNamespace: kLoopMeNamespaceVideo
                 param: [NSNumber numberWithFloat: fullDuration]];
}

- (void)setCurrentTime: (CGFloat)currentTime {
    [self executeEvent: LoopMeEvent.currentTime
          forNamespace: kLoopMeNamespaceVideo
                 param: [NSNumber numberWithFloat: currentTime]];
}

- (void)setShake {
    [self executeEvent: LoopMeEvent.shake
          forNamespace: kLoopMeNamespaceWebview
                 param: @YES
             paramBOOL: YES];
}

- (void)setFullScreenModeEnabled: (BOOL)enabled {
    [self executeEvent: LoopMeEvent.fullscreenMode
          forNamespace: kLoopMeNamespaceWebview
                 param: @(enabled)
             paramBOOL: YES];
}

@end
