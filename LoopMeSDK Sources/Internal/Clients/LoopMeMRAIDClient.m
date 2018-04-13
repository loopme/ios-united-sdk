//
//  LoopMeMRAIDClient.m
//  LoopMeSDK
//
//  Created by Bohdan Korda on 10/24/16.
//  Copyright © 2016 LoopMe. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "LoopMeAdWebView.h"
#import "LoopMeDefinitions.h"
#import "LoopMeMRAIDClient.h"
#import "LoopMeVideoCommunicatorProtocol.h"
#import "NSURL+LoopMeAdditions.h"
#import "LoopMeLogging.h"

NSString * const _kLoopMeMRAIDURLScheme = @"mraid";

NSString * const _kLoopMeMRAIDSupportsSMS = @"sms";
NSString * const _kLoopMeMRAIDSupportsTel = @"tel";
NSString * const _kLoopMeMRAIDSupportsCalendar = @"calendar";
NSString * const _kLoopMeMRAIDSupportsStorePicture = @"storePicture";
NSString * const _kLoopMeMRAIDSupportsInlineVideo = @"inlineVideo";

//// Commands
NSString * const _kLoopMeMRAIDOpenCommand = @"open";
NSString * const _kLoopMeMRAIDPlayVideoCommand = @"playVideo";
NSString * const _kLoopMeMRAIDResizeCommand = @"resize";
NSString * const _kLoopMeMRAIDCustomCloseCommand = @"useCustomClose";
NSString * const _kLoopMeMRAIDSetOrientationPropertiesCommand = @"setOrientationProperties";
NSString * const _kLoopMeMRAIDSetResizePropertiesCommand = @"setResizeProperties";
NSString * const _kLoopMeMRAIDStorePictureCommand = @"storePicture";
NSString * const _kLoopMeMRAIDCreateCalendarEventCommand = @"createCalendarEvent";
NSString * const _kLoopMeMRAIDCloseCommand = @"close";
NSString * const _kLoopMeMRAIDExpandCommand = @"expand";

// Events
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

const struct LoopMeMRAIDStateStruct LoopMeMRAIDState = {
    .loading = @"loading",
    .defaultt = @"default",
    .expanded = @"expanded",
    .resized = @"resized",
    .hidden = @"hidden"
};

@interface LoopMeMRAIDClient ()

@property (nonatomic, weak) id<LoopMeMRAIDClientDelegate> delegate;
@property (nonatomic, weak, readonly) UIWebView *webViewClient;

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

- (UIWebView *)webViewClient {
    return [self.delegate webViewTransport];
}

#pragma mark - Private

#pragma mark JS Commands

- (void)processCommand:(NSString *)command withParams:(NSDictionary *)params {
    
    if ([command isEqualToString:_kLoopMeMRAIDOpenCommand]) {
        [self.delegate mraidClient:self shouldOpenURL:[NSURL lm_urlWithEncodedString:params[@"url"]]];
    } else if ([command isEqualToString:_kLoopMeMRAIDPlayVideoCommand]) {
        [self.delegate mraidClient:self sholdPlayVideo:[NSURL lm_urlWithEncodedString:params[@"url"]]];
    } else if ([command isEqualToString:_kLoopMeMRAIDResizeCommand]) {
        [self.delegate mraidClientDidResizeAd:self];
    } else if ([command isEqualToString:_kLoopMeMRAIDCustomCloseCommand]) {
        [self.delegate mraidClient:self useCustomClose:[params[@"useCustomClose"] boolValue]];
    } else if ([command isEqualToString:_kLoopMeMRAIDSetOrientationPropertiesCommand]) {
        NSDictionary *orientationProperties = @{@"allowOrientationChange" : params[@"allowOrientationChange"], @"forceOrientation" : params[@"forceOrientation"]};
        [self.delegate mraidClient:self setOrientationProperties:orientationProperties];
    } else if ([command isEqualToString:_kLoopMeMRAIDSetResizePropertiesCommand]) {
        
    } else if ([command isEqualToString:_kLoopMeMRAIDStorePictureCommand]) {
        
    } else if ([command isEqualToString:_kLoopMeMRAIDCreateCalendarEventCommand]) {
        
    } else if ([command isEqualToString:_kLoopMeMRAIDCloseCommand]) {
        [self.delegate mraidClientDidReceiveCloseCommand:self];
    } else if ([command isEqualToString:_kLoopMeMRAIDExpandCommand]) {
        [self.delegate mraidClientDidReceiveExpandCommand:self];
    } else {
        LoopMeLogDebug(@"JS command: %@ is not supported", command);
    }
}

#pragma mark JS Events

- (NSString *)makeEventStringForEvent:(NSString *)event params:(NSString *)params {
    NSString *eventString = [NSString stringWithFormat:@"mraid.%@(%@)", event, params];
    return eventString;
}

#pragma mark - Public

- (NSDictionary *)getOrientationProperties {
    NSString *stringOrientationProperties = [self.webViewClient stringByEvaluatingJavaScriptFromString:@"mraid.getStringOrientationProperties()"];
    return [NSJSONSerialization JSONObjectWithData:[stringOrientationProperties dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
}

- (NSDictionary *)getResizeProperties {
    NSString *stringOrientationProperties = [self.webViewClient stringByEvaluatingJavaScriptFromString:@"mraid.getStringResizeProperties()"];
    return [NSJSONSerialization JSONObjectWithData:[stringOrientationProperties dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
}

- (NSDictionary *)getExpandProperties {
    NSString *stringExpandProperties = [self.webViewClient stringByEvaluatingJavaScriptFromString:@"mraid.getStringExpandProperties()"];
    return [NSJSONSerialization JSONObjectWithData:[stringExpandProperties dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
}

- (NSString *)getState {
    return [self.webViewClient stringByEvaluatingJavaScriptFromString:@"mraid.getStateString()"];
}

- (void)executeEvent:(NSString *)event params:(NSArray *)params {
    NSMutableString *stringParams = [NSMutableString new];
    if (params.count) {
        for (id param in params) {
            NSString *formatedParam;
            if ([param isKindOfClass:[NSString class]]) {
                if ([param isEqualToString:@"true"] || [param isEqualToString:@"false"]) {
                    formatedParam = [NSString stringWithFormat:@"%@,", param];
                } else {
                    formatedParam = [NSString stringWithFormat:@"'%@',", param];
                }
                
            } else if ([param isKindOfClass:[NSNumber class]]) {
               formatedParam = [NSString stringWithFormat:@"%ld,", (long)[param integerValue]];
            }
            [stringParams appendString:formatedParam];
        }
        //remove last ','
        stringParams = [[stringParams substringToIndex:[stringParams length] - 1] mutableCopy];
    }
    
    NSString *eventString = [self makeEventStringForEvent:event params:stringParams];
    [self.webViewClient stringByEvaluatingJavaScriptFromString:eventString];
}

- (void)setSupports {
    NSArray *mraidFeatures = @[
                               _kLoopMeMRAIDSupportsSMS,
                               _kLoopMeMRAIDSupportsTel,
                               _kLoopMeMRAIDSupportsCalendar,
                               _kLoopMeMRAIDSupportsStorePicture,
                               _kLoopMeMRAIDSupportsInlineVideo,
                               ];
    for (id aFeature in mraidFeatures) {
        if ([aFeature isEqualToString:_kLoopMeMRAIDSupportsCalendar] || [aFeature isEqualToString:_kLoopMeMRAIDSupportsStorePicture]) {
            [self executeEvent:LoopMeMRAIDFunctions.setSupports params:@[aFeature, @"false"]];
        } else {
            [self executeEvent:LoopMeMRAIDFunctions.setSupports params:@[aFeature, @"true"]];
        }
    }
}


- (BOOL)shouldInterceptURL:(NSURL *)URL {
    return [URL.scheme.lowercaseString isEqualToString:_kLoopMeMRAIDURLScheme];
}

- (void)processURL:(NSURL *)URL {
    NSString *command = URL.host;
    NSDictionary *params = [URL lm_toDictionary];
    LoopMeLogDebug(@"Processing MRAID command: %@, params: %@", command, params);
    [self processCommand:command withParams:params];
}

@end
