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

#pragma mark - Private

#pragma mark JS Commands

- (void)processCommand:(NSString *)command withParams:(NSDictionary *)params {
    LoopMeLogDebug(@"Processing MRAID command: %@, params: %@", command, params);
    
    if ([command isEqualToString:_kLoopMeMRAIDOpenCommand]) {
        [self.delegate mraidClient:self shouldOpenURL:[NSURL lm_urlWithEncodedString:params[@"url"]]];
    } else if ([command isEqualToString:_kLoopMeMRAIDPlayVideoCommand]) {
        [self.delegate mraidClient:self sholdPlayVideo:[NSURL lm_urlWithEncodedString:params[@"url"]]];
    } else if ([command isEqualToString:_kLoopMeMRAIDResizeCommand]) {
        NSDictionary *resizeProperties = params[@"resizeProperties"];
        self.resizeProperties = resizeProperties;
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
        NSDictionary *expandProperties = params[@"expandProperties"];
        self.expandProperties = expandProperties;
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

//- (void)getOrientationProperties:(void (^)(NSDictionary *))completion {
//    [self.webViewClient evaluateJavaScript:@"mraid.getStringOrientationProperties()" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//
//        NSString *stringOrientationProperties;
//
//        if (!error) {
//            stringOrientationProperties = [result string];
//        } else {
////            completion(@{});
//            return;
//        }
//
//        NSDictionary *orientationProperties = [NSJSONSerialization JSONObjectWithData:[stringOrientationProperties dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
//
//        completion(orientationProperties);
//    }];
//}
//
//- (void)getExpandProperties:(void (^)(NSDictionary *))completion {
//    [self.webViewClient evaluateJavaScript:@"mraid.getStringExpandProperties()" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//
//        NSString *stringExpandProperties;
//
//        if (!error) {
//            stringExpandProperties = [result string];
//        } else {
//            return;
//        }
//
//        NSDictionary *expandProperties = [NSJSONSerialization JSONObjectWithData:[stringExpandProperties dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
//
//        completion(expandProperties);
//    }];
//}

//- (void)getResizeProperties:(void (^)(NSDictionary *))completion {
//    [self.webViewClient evaluateJavaScript:@"mraid.getStringResizeProperties()" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//        
//        NSString *stringResizeProperties;
//        
//        if (!error) {
//            stringResizeProperties = [result string];
//        } else {
//            return;
//        }
//        
//        NSDictionary *resizeProperties = [NSJSONSerialization JSONObjectWithData:[stringResizeProperties dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
//        
//        completion(resizeProperties);
//    }];
//}
//
//- (void)getState:(void (^)(NSString *))completion {
//    [self.webViewClient evaluateJavaScript:@"mraid.getStateString()" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//        
//        NSString *state;
//        
//        if (!error) {
//            state = [result string];
//        } else {
//            return;
//        }
//        
//        completion(state);
//    }];
//}

- (void)executeEvent:(NSString *)event params:(NSArray *)params {
    
    if ([event isEqualToString:LoopMeMRAIDFunctions.stateChange]) {
        self.state = params.firstObject;
    }
    
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
    [self.webViewClient evaluateJavaScript:eventString completionHandler:nil];
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
    
    [self processCommand:command withParams:params];
}

@end
