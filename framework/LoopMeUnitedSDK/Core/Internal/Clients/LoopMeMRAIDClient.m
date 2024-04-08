//
//  LoopMeMRAIDClient.m
//  LoopMeSDK
//
//  Created by Bohdan Korda on 10/24/16.
//  Copyright © 2016 LoopMe. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <WebKit/WebKit.h>

#import "LoopMeAdWebView.h"
#import "LoopMeDefinitions.h"
#import "LoopMeMRAIDClient.h"
#import "LoopMeVideoCommunicatorProtocol.h"
#import "NSURL+LoopMeAdditions.h"
#import "LoopMeLogging.h"

/// Functions
const struct LoopMeMRAIDFunctionsStruct LoopMeMRAIDFunctions = {
    .ready = @"fireReadyEvent",
    .error = @"fireErrorEvent",
    .sizeChange = @"fireSizeChangeEvent",
    .stateChange = @"fireStateChangeEvent",
    .viewableChange = @"fireViewableChangeEvent",
    .setScreenSize = @"setScreenSize",
    .setPlacementType = @"setPlacementType",
    .setSupports = @"setSupports",
    .setCurrentPosition = @"setCurrentPosition",
    .setDefaultPosition = @"setDefaultPosition",
    .setMaxSize = @"setMaxSize",
    .setExpandSize = @"setExpandSize"
};

/// States
const struct LoopMeMRAIDStateStruct LoopMeMRAIDState = {
    .loading = @"loading",
    .defaultt = @"default",
    .expanded = @"expanded",
    .resized = @"resized",
    .hidden = @"hidden"
};

/// Events
const struct LoopMeMRAIDEventStruct LoopMeMRAIDEvent ={
    .open = @"open",
    .playVideo = @"playVideo",
    .resize = @"resize",
    .useCustomClose = @"useCustomClose",
    .setOrientationProperties = @"setOrientationProperties",
    .setResizeProperties = @"setResizeProperties",
    .storePicture = @"storePicture",
    .createCalendarEvent = @"createCalendarEvent",
    .close = @"close",
    .expand = @"expand"
};

@interface LoopMeMRAIDClient ()

@property (nonatomic, weak) id<LoopMeMRAIDClientDelegate> delegate;
@property (nonatomic, weak, readonly) WKWebView *webViewClient;

@end

@implementation LoopMeMRAIDClient

#pragma mark - Life Cycle

- (instancetype)initWithDelegate:(id<LoopMeMRAIDClientDelegate>)deleagate {
    if (self = [super init]) {
        _delegate = deleagate;
    }
    return self;
}

#pragma mark - Properties

- (WKWebView *)webViewClient {
    return [self.delegate webViewTransport];
}

#pragma mark JS Commands

- (void)processCommand:(NSString *)command withParams:(NSDictionary *)params {
    LoopMeLogDebug(@"Processing MRAID command: %@, params: %@", command, params);

    void (^selectedCase)(void) = @{
        LoopMeMRAIDEvent.open: ^{
            [self.delegate mraidClient: self
                         shouldOpenURL: [NSURL lm_urlWithEncodedString: params[@"url"]]];
        },
        LoopMeMRAIDEvent.playVideo: ^{
            [self.delegate mraidClient: self
                        sholdPlayVideo: [NSURL lm_urlWithEncodedString: params[@"url"]]];
        },
        LoopMeMRAIDEvent.resize: ^{
            self.resizeProperties = params[@"resizeProperties"];
            [self.delegate mraidClientDidResizeAd: self];
        },
        LoopMeMRAIDEvent.useCustomClose: ^{
            [self.delegate mraidClient: self
                        useCustomClose: [params[@"useCustomClose"] boolValue]];
        },
        LoopMeMRAIDEvent.setOrientationProperties: ^{
            [self.delegate mraidClient: self
              setOrientationProperties: @{
                @"allowOrientationChange": params[@"allowOrientationChange"],
                @"forceOrientation": params[@"forceOrientation"]
            }];
        },
        LoopMeMRAIDEvent.close: ^{
            [self.delegate mraidClientDidReceiveCloseCommand: self];
        },
        LoopMeMRAIDEvent.expand: ^{
            self.expandProperties = params[@"expandProperties"];
            [self.delegate mraidClientDidReceiveExpandCommand: self];
        },
    }[command];

    if (selectedCase != nil) {
        selectedCase();
    } else {
        LoopMeLogDebug(@"MRAID command: %@ is not supported", command);
    }
}

#pragma mark - Public

- (void)executeEvent:(NSString *)event params:(NSArray *)params {
    if ([event isEqualToString: LoopMeMRAIDFunctions.stateChange]) {
        self.state = params.firstObject;
    }
    
    NSMutableString *stringParams = [NSMutableString new];
    for (id param in params) {
        if ([param isKindOfClass: [NSString class]]) {
            NSString *format = [@[@"true", @"false"] containsObject: param] ? @"%@," : @"'%@',";
            [stringParams appendString: [NSString stringWithFormat: format, param]];
        }
        if ([param isKindOfClass: [NSNumber class]]) {
            [stringParams appendString: [NSString stringWithFormat: @"%ld,", (long)[param integerValue]]];
        }
    }
    if (params.count) {
        // remove last ','
        stringParams = [[stringParams substringToIndex: [stringParams length] - 1] mutableCopy];
    }
    
    [self.webViewClient evaluateJavaScript: [NSString stringWithFormat: @"mraid.%@(%@)", event, stringParams]
                         completionHandler: nil];
}

- (void)setSupports {
    for (NSArray *params in @[
        @[@"calendar", @"false"],
        @[@"storePicture", @"false"],
        @[@"sms", @"true"],
        @[@"tel", @"true"],
        @[@"inlineVideo", @"true"]
    ]) {
        [self executeEvent: LoopMeMRAIDFunctions.setSupports params: params];
    }
}

- (BOOL)shouldInterceptURL:(NSURL *)URL {
    return [URL.scheme.lowercaseString isEqualToString: @"mraid"];
}

- (void)processURL:(NSURL *)URL {
    [self processCommand: URL.host withParams: [URL lm_toDictionary]];
}

@end
