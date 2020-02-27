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

NSString * const _kLoopMeURLScheme = @"loopme";

// Commands
NSString * const _kLoopMeSuccessCommand = @"success";
NSString * const _kLoopMeFailLoadCommand = @"fail";
NSString * const _kLoopMeCloseCommand = @"close";
NSString * const _kLoopMePlayCommand = @"play";
NSString * const _kLoopMeStopCommand = @"pause";
NSString * const _kLoopMeMuteCommand = @"mute";
NSString * const _kLoopMeLoadCommand = @"load";
NSString * const _kLoopMeVibrateCommand = @"vibrate";
NSString * const _kLoopMeEnableStretchCommand = @"enableStretching";
NSString * const _kLoopMeDisableStretchCommand = @"disableStretching";
NSString * const _kLoopMeFullScreenCommand = @"fullscreenMode";

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

const struct LoopMe360EventStruct LoopMe360Event = {
    .swipe = @"swipe",
    .gyro = @"gyro",
    .front = @"front",
    .left = @"left",
    .right = @"right",
    .back = @"back",
    .zoom = @"zoom"
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
@property (nonatomic, strong) NSMutableSet *events360;

- (void)loadVideoWithParams:(NSDictionary *)params;
- (void)playVideoWithParams:(NSDictionary *)params;
- (void)pauseVideoWithParams:(NSDictionary *)params;
@end

@implementation LoopMeJSClient

#pragma mark - Life Cycle

- (void)dealloc {
    
}

- (instancetype)initWithDelegate:(id<LoopMeJSClientDelegate>)deleagate {
    if (self = [super init]) {
        _delegate = deleagate;
        _events360 = [[NSMutableSet alloc] init];
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

- (void)loadVideoWithParams:(NSDictionary *)params {
    NSString *videoSource = params[@"src"];
    [self.videoClient loadWithURL:[NSURL lm_urlWithEncodedString:videoSource]];
}

- (void)playVideoWithParams:(NSDictionary *)params {
    NSString *time = params[@"currentTime"];
    double timeToPlay = (time) ? [time doubleValue] : -1;
    [self.videoClient playFromTime:timeToPlay];
}

- (void)pauseVideoWithParams:(NSDictionary *)params {
    NSString *time = params[@"currentTime"];
    double timeToPause = (time) ? [time doubleValue] : -1;
    [self.videoClient pauseOnTime:timeToPause];
}

- (void)muteVideoWithParams:(NSDictionary *)params {
    NSString *muteString = params[@"mute"];
    BOOL mute = [muteString isEqual:@"true"] ? YES : NO;
    [self.videoClient setMute:mute];
}

#pragma mark JS Commands

- (void)processCommand:(NSString *)command forNamespace:(NSString *)ns withParams:(NSDictionary *)params {
    LoopMeLogDebug(@"JS command: %@", command);

    if ([ns isEqualToString:kLoopMeNamespaceWebview]) {
        [self processWebViewCommand:command withParams:params];
    } else if ([ns isEqualToString:kLoopMeNamespaceVideo]) {
        [self processVideoCommand:command withParams:params];
    } else {
        LoopMeLogDebug(@"Namespace: %@ is not supported", ns);
    }
}

- (void)processWebViewCommand:(NSString *)command withParams:(NSDictionary *)params {
    if ([command isEqualToString:_kLoopMeSuccessCommand]) {
        [self.delegate JSClientDidReceiveSuccessCommand:self];
    } else if ([command isEqualToString:_kLoopMeFailLoadCommand]) {
        [self.delegate JSClientDidReceiveFailCommand:self];
    } else if ([command isEqualToString:_kLoopMeCloseCommand]) {
        [self.delegate JSClientDidReceiveCloseCommand:self];
    } else if ([command isEqualToString:_kLoopMeVibrateCommand]) {
        [self.delegate JSClientDidReceiveVibrateCommand:self];
    } else if ([command isEqualToString:_kLoopMeFullScreenCommand]) {
        [self.delegate JSClientDidReceiveFulLScreenCommand:self fullScreen:[params[@"mode"] boolValue]];
    } else {
        LoopMeLogDebug(@"JS command: %@ for namespace: %@ is not supported", command, @"webview");
    }
}

- (void)processVideoCommand:(NSString *)command withParams:(NSDictionary *)params {
    if ([command isEqualToString:_kLoopMeLoadCommand]) {
        [self loadVideoWithParams:params];
    } else if ([command isEqualToString:_kLoopMePlayCommand]) {
        [self playVideoWithParams:params];
    } else if ([command isEqualToString:_kLoopMeStopCommand]) {
        [self pauseVideoWithParams:params];
    } else if ([command isEqualToString:_kLoopMeMuteCommand]) {
        [self muteVideoWithParams:params];
    } else if ([command isEqualToString:_kLoopMeEnableStretchCommand]) {
        [self.videoClient setGravity:AVLayerVideoGravityResize];
    } else if ([command isEqualToString:_kLoopMeDisableStretchCommand]) {
        [self.videoClient setGravity:AVLayerVideoGravityResizeAspect];
    } else {
        LoopMeLogDebug(@"JS command: %@ for namespace: %@ is not supported", command, @"video");
    }
}

#pragma mark JS Events

- (NSString *)makeEventStringForEvent:(NSString *)event namespace:(NSString *)ns withParam:(NSObject *)param paramBOOL:(BOOL)isBOOL {
    if (isBOOL == YES) {
        param = [(NSNumber *)param boolValue] == YES ? @"true" : @"false";
    } else if ([param isKindOfClass:[NSString class]]) {
        param = [NSString stringWithFormat:@"\"%@\"", param];
    }
    NSString *eventString = [NSString stringWithFormat:@"L.bridge.set(\"%@\",{%@:%@})", ns, event, param];
    return eventString;
}

#pragma mark - Public

- (void)executeInteractionCustomEvent:(NSString *)customEventName {
    if (![self.events360 containsObject:customEventName]) {
        NSString *eventString = [NSString stringWithFormat:@"L.track({eventType:\"INTERACTION\", customEventName: \"video360&mode=%@\"})", customEventName];
        [self.webViewClient evaluateJavaScript:eventString completionHandler:nil];
        
        [self.events360 addObject:customEventName];
    }
}

- (void)executeEvent:(NSString *)event forNamespace:(NSString *)ns param:(NSObject *)param {
    [self executeEvent:event forNamespace:ns param:param paramBOOL:NO];
}

- (void)executeEvent:(NSString *)event forNamespace:(NSString *)ns param:(NSObject *)param paramBOOL:(BOOL)isBOOL {
    NSString *eventString = [self makeEventStringForEvent:event namespace:ns withParam:param paramBOOL:isBOOL];
    [self.webViewClient evaluateJavaScript:eventString completionHandler:nil];
}

- (BOOL)shouldInterceptURL:(NSURL *)URL {
    return [URL.scheme.lowercaseString isEqualToString:_kLoopMeURLScheme];
}

- (void)processURL:(NSURL *)URL {
    NSString *ns = URL.host;
    NSString *command = URL.lastPathComponent;
    NSDictionary *params = [URL lm_toDictionary];
    LoopMeLogDebug(@"Processing JS command: %@, namespace: %@, params: %@", command, ns, params);
    [self processCommand:command forNamespace:ns withParams:params];
}

#pragma mark - LoopMeJSTransportProtocol

- (void)setVideoState:(NSString *)state {
    [self executeEvent:LoopMeEvent.state forNamespace:kLoopMeNamespaceVideo param:state];
}

- (void)setWebViewState:(NSString *)state {
    [self executeEvent:LoopMeEvent.state forNamespace:kLoopMeNamespaceWebview param:state];
}

- (void)setDuration:(CGFloat)fullDuration {
    [self executeEvent:LoopMeEvent.duration forNamespace:kLoopMeNamespaceVideo param:[NSNumber numberWithFloat:fullDuration]];
}

- (void)setCurrentTime:(CGFloat)currentTime {
    [self executeEvent:LoopMeEvent.currentTime forNamespace:kLoopMeNamespaceVideo param:[NSNumber numberWithFloat:currentTime]];
}

- (void)setShake {
    [self executeEvent:LoopMeEvent.shake forNamespace:kLoopMeNamespaceWebview param:@YES paramBOOL:YES];
}

- (void)setFullScreenModeEnabled:(BOOL)enabled {
    [self executeEvent:LoopMeEvent.fullscreenMode forNamespace:kLoopMeNamespaceWebview param:@(enabled) paramBOOL:YES];
}

- (void)track360LeftSector {
    [self executeInteractionCustomEvent:LoopMe360Event.left];
}

- (void)track360BackSector {
    [self executeInteractionCustomEvent:LoopMe360Event.back];
}

- (void)track360FrontSector {
    [self executeInteractionCustomEvent:LoopMe360Event.front];
}

- (void)track360RightSector {
    [self executeInteractionCustomEvent:LoopMe360Event.right];
}

- (void)track360Gyro {
    [self executeInteractionCustomEvent:LoopMe360Event.gyro];
}

- (void)track360Swipe {
    [self executeInteractionCustomEvent:LoopMe360Event.swipe];
}

- (void)track360Zoom {
    [self executeInteractionCustomEvent:LoopMe360Event.zoom];
}

@end
