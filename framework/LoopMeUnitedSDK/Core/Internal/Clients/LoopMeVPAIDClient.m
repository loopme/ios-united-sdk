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

@end

@implementation LoopMeVPAIDClient

#pragma mark - Life Cycle

- (instancetype)initWithDelegate: (id<LoopMeVpaidProtocol>)deleagate webView: (WKWebView *)webView {
    if (self = [super init]) {
        _delegate = deleagate;
        _webViewClient = webView;
    }
    return self;
}

#pragma mark - Public

- (double)handshakeVersion {
    return 2;
}

- (void)initAdWithWidth: (int)width
                 height: (int)height
               viewMode: (NSString *)viewMode
         desiredBitrate: (double)desiredBitrate
           creativeData: (NSString *)creativeData {
    [self callMethod: @"initAd" arguments: @[
        @(width),
        @(height),
        [NSString stringWithFormat: @"'%@'", viewMode],
        @(desiredBitrate),
        [NSString stringWithFormat: @"%@", [@{ @"AdParameters" : creativeData } lm_jsonStringWithPrettyPrint: NO]]
    ]];
}

- (void)resizeAdWithWidth: (int)width height: (int)height viewMode: (NSString *)viewMode {
    [self callMethod: @"resizeAd" arguments: @[@(width), @(height), [NSString stringWithFormat: @"'%@'", viewMode]]];
}

- (void)setAdVolume: (double)volume {
    [self callMethod: @"setAdVolume" arguments: @[@(volume)]];
}

- (void)startAd {
    [self callMethod: @"startAd" arguments: @[]];
}

- (void)stopAd {
    [self callMethod: @"stopAd" arguments: @[]];
}

- (void)pauseAd {
    [self callMethod: @"pauseAd" arguments: @[]];
}

- (void)resumeAd {
    [self callMethod: @"resumeAd" arguments: @[]];
}

- (void)expandAd {
    [self callMethod: @"expandAd" arguments: @[]];
}

- (void)collapseAd {
    [self callMethod: @"collapseAd" arguments: @[]];
}

- (void)skipAd {
    [self callMethod: @"skipAd" arguments: @[]];
}

#pragma mark - private

- (void)callMethod: (NSString *)method arguments: (NSArray *)arguments {
    NSMutableString *argumentsAsString = [[arguments componentsJoinedByString: @","] mutableCopy];
    argumentsAsString = [[argumentsAsString stringByReplacingOccurrencesOfString: @"\n" withString: @""] mutableCopy];
    argumentsAsString = [[argumentsAsString stringByReplacingOccurrencesOfString: @"\r" withString: @""] mutableCopy];
    [self.webViewClient evaluateJavaScript: [NSString stringWithFormat: @"getVPAIDWrapper().%@(%@)", method, argumentsAsString]
                         completionHandler: nil];
}

@end
