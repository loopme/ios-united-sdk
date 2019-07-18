//
//  LoopMeDVSDKWrapper.m
//  LoopMeSDK
//
//  Created by Bohdan on 12/15/16.
//  Copyright © 2016 LoopMe. All rights reserved.
//

#import "LoopMeIASWrapper.h"

static NSString * const kLoopMeIASLoggingJSPath = @"https://mobile-static.adsafeprotected.com/static/creative/avid-certification/scripts/placement-avid-logging.js?placementId=%@";
static NSString * const kLoopMeIASCMTagPath = @"https://pixel.adsafeprotected.com/jload?anId=927083&advId=%@&campId=%@&pubId=%@&chanId=%@&placementId=%@&adsafe_par=1&bundleId=%@";


extern const struct LoopMeIASEventsStruct {
    __unsafe_unretained NSString *adImp;
    __unsafe_unretained NSString *adStarted;
    __unsafe_unretained NSString *adLoaded;
    __unsafe_unretained NSString *videoStart;
    __unsafe_unretained NSString *adStopped;
    __unsafe_unretained NSString *adComplete;
    __unsafe_unretained NSString *adClickThru;
    __unsafe_unretained NSString *adVideoFirstQuartile;
    __unsafe_unretained NSString *adVideoMidpoint;
    __unsafe_unretained NSString *adVideoThirdQuartile;
    __unsafe_unretained NSString *adPaused;
    __unsafe_unretained NSString *adPlaying;
    __unsafe_unretained NSString *adExpandedChange;
    __unsafe_unretained NSString *adUserMinimize;
    __unsafe_unretained NSString *adUserAcceptInvitation;
    __unsafe_unretained NSString *adUserClose;
    __unsafe_unretained NSString *adSkipped;
    __unsafe_unretained NSString *adEnteredFullscreen;
    __unsafe_unretained NSString *adExitedFullscreen;
    
    __unsafe_unretained NSString *adVolumeChangeEvent;
    __unsafe_unretained NSString *adDurationChange;
    __unsafe_unretained NSString *adError;
    
} LoopMeIASEvents;

const struct LoopMeIASEventsStruct LoopMeIASEvents =
{
    .adImp = @"recordAdImpressionEvent",
    .adStarted = @"recordAdStartedEvent",
    .adLoaded = @"recordAdLoadedEvent",
    .videoStart = @"recordAdVideoStartEvent",
    .adStopped = @"recordAdStoppedEvent",
    .adComplete = @"recordAdCompleteEvent",
    .adClickThru = @"recordAdClickThruEvent",
    .adVideoFirstQuartile = @"recordAdVideoFirstQuartileEvent",
    .adVideoMidpoint = @"recordAdVideoMidpointEvent",
    .adVideoThirdQuartile = @"recordAdVideoThirdQuartileEvent",
    .adPaused = @"recordAdPausedEvent",
    .adPlaying = @"recordAdPlayingEvent",
    .adExpandedChange = @"recordAdExpandedChangeEvent",
    .adUserMinimize = @"recordAdUserMinimizeEvent",
    .adUserAcceptInvitation = @"recordAdUserAcceptInvitationEvent",
    .adUserClose = @"recordAdUserCloseEvent",
    .adSkipped = @"recordAdSkippedEvent",
    .adEnteredFullscreen = @"recordAdEnteredFullscreenEvent",
    .adExitedFullscreen = @"recordAdExitedFullscreenEvent",
    
    .adVolumeChangeEvent = @"recordAdVolumeChangeEvent:",
    .adDurationChange = @"recordAdDurationChangeEvent",
    .adError = @"recordAdErrorWithMessage:"
};

@interface LoopMeIASWrapper ()

@property (nonatomic, strong) NSMutableSet *sentEvents;

@property (nonatomic, strong) LoopMe_ExternalAvidAdSessionContext *iasContext;
@property (nonatomic, strong) LoopMe_AbstractAvidAdSession *iasAdSession;
@property (nonatomic, weak) id<LoopMe_AvidVideoPlaybackListener> avidVideoListener;
@property (nonatomic, assign) BOOL ready;

@end

@implementation LoopMeIASWrapper


- (instancetype)init {
    self = [super init];
    if (self) {
        self.sentEvents = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)initWithPartnerVersion:(NSString *)version creativeType:(LoopMeCreativeType)creativeType adConfiguration:(LoopMeAdConfiguration *)configuration {
    
    NSString *spotName = [[NSUserDefaults standardUserDefaults] valueForKey:@"adSpotName"];
    
    NSDictionary *adIds = configuration.adIdsForIAS;
    
//    NSString *loggingJSPath = [NSString stringWithFormat:kLoopMeIASLoggingJSPath, spotName];
    
    NSString *cmPath = [NSString stringWithFormat:kLoopMeIASCMTagPath, [adIds objectForKey:@"advId"], [adIds objectForKey:@"campId"], [adIds objectForKey:@"pubId"], [adIds objectForKey:@"chanId"], spotName, [adIds objectForKey:@"bundleId"]];
    
    self.iasContext = [LoopMe_ExternalAvidAdSessionContext contextWithPartnerVersion:version isDeferred:YES];
    
    switch (creativeType) {
        case LoopMeCreativeTypeVAST:
            self.iasAdSession = [LoopMe_AvidAdSessionManager startAvidManagedVideoAdSessionWithContext:self.iasContext];
            self.avidVideoListener = [(LoopMe_AvidManagedVideoAdSession *)self.iasAdSession avidVideoPlaybackListener];
//            [(LoopMe_AvidManagedVideoAdSession *)self.iasAdSession injectJavaScriptResource:loggingJSPath];
            [(LoopMe_AvidManagedVideoAdSession *)self.iasAdSession injectJavaScriptResource:cmPath];
            
            break;
        case LoopMeCreativeTypeMRAID:
        case LoopMeCreativeTypeNormal:
            self.iasAdSession = [LoopMe_AvidAdSessionManager startAvidDisplayAdSessionWithContext:self.iasContext];
            
            //            configuration.adResponseHTMLString = [self injectJS:loggingJSPath intoHTML:configuration.adResponseHTMLString];
            configuration.creativeContent = [self injectJS:cmPath intoHTML:configuration.creativeContent];
            break;
        default:
            break;
    }
}

- (NSString *)injectJS:(NSString *)path intoHTML:(NSString *)html {
    NSMutableString *mutableHTML = [html mutableCopy];
    NSRange range = [html rangeOfString:@"<script>"];
    NSString *scriptString = [NSString stringWithFormat:@"<script src=\"%@\"></script>", path];
    [mutableHTML insertString:scriptString atIndex:range.location];
    return mutableHTML;
}

- (NSString *)injectFWMonitoringTag:(NSString *)tag intoHTML:(NSString *)html {
    NSString *scriptString = [NSString stringWithFormat:@"<SCRIPT TYPE=\"application/javascript\" SRC=\"%@\"></SCRIPT>", tag];
    
    NSMutableString *mutableHTML = [html mutableCopy];
    NSRange range = [html rangeOfString:@"<script>"];
    [mutableHTML insertString:scriptString atIndex:range.location];
    return mutableHTML;
}

- (NSString *)avidAdSessionId {
    return [self.iasAdSession avidAdSessionId];
}

- (void)recordReadyEvent {
    if (!self.ready) {
        self.ready = YES;
        [[self.iasAdSession avidDeferredAdSessionListener] recordReadyEvent];
    }
}

- (void)registerAdView:(UIView *)view {
    [self.iasAdSession registerAdView:view];
}

- (void)unregisterAdView:(UIView *)view {
    [self.iasAdSession unregisterAdView:view];
}

- (void)endSession {
    [self.iasAdSession endSession];
}

- (void)registerFriendlyObstruction:(UIView *)friendlyObstruction {
    [self.iasAdSession registerFriendlyObstruction:friendlyObstruction];
}

- (void)recordAdLoadedEvent {
    [self recordEvent:LoopMeIASEvents.adLoaded];
}

- (void)recordAdPausedEvent {
    [self recordEvent:LoopMeIASEvents.adPaused];
}

- (void)recordAdPlayingEvent {
    [self recordEvent:LoopMeIASEvents.adPlaying];
}

- (void)recordAdSkippedEvent {
    [self recordEvent:LoopMeIASEvents.adSkipped];
}

- (void)recordAdStartedEvent {
    [self recordEvent:LoopMeIASEvents.adStarted];
}

- (void)recordAdStoppedEvent {
    [self recordEvent:LoopMeIASEvents.adStopped];
}

- (void)recordAdCompleteEvent {
    [self recordEvent:LoopMeIASEvents.adComplete];
}

- (void)recordAdClickThruEvent {
    [self recordEvent:LoopMeIASEvents.adClickThru];
}

- (void)recordAdUserCloseEvent {
    [self recordEvent:LoopMeIASEvents.adUserClose];
}

- (void)recordAdImpressionEvent {
    [self recordEvent:LoopMeIASEvents.adImp];
}

- (void)recordAdVideoStartEvent {
    [self recordEvent:LoopMeIASEvents.videoStart];
}

- (void)recordAdUserMinimizeEvent {
    [self recordEvent:LoopMeIASEvents.adUserMinimize];
}

- (void)recordAdVideoMidpointEvent {
    [self recordEvent:LoopMeIASEvents.adVideoMidpoint];
}

- (void)recordAdExpandedChangeEvent {
    [self recordEvent:LoopMeIASEvents.adExpandedChange];
}

- (void)recordAdExitedFullscreenEvent {
    [self recordEvent:LoopMeIASEvents.adExitedFullscreen];
}

- (void)recordAdEnteredFullscreenEvent {
    [self recordEvent:LoopMeIASEvents.adEnteredFullscreen];
}

- (void)recordAdVideoFirstQuartileEvent {
    [self recordEvent:LoopMeIASEvents.adVideoFirstQuartile];
}

- (void)recordAdVideoThirdQuartileEvent {
    [self recordEvent:LoopMeIASEvents.adVideoThirdQuartile];
}

- (void)recordAdUserAcceptInvitationEvent {
    [self recordEvent:LoopMeIASEvents.adUserAcceptInvitation];
}

- (void)recordAdErrorWithMessage:(NSString *)message {
    NSString *type = LoopMeIASEvents.adError;
    if (![self.sentEvents containsObject:type]) {
        [self.avidVideoListener recordAdErrorWithMessage:message];
        [self.sentEvents addObject:type];
    }
}

- (void)recordAdVolumeChangeEvent:(NSInteger)volume {
    NSString *type = LoopMeIASEvents.adVolumeChangeEvent;
    if (![self.sentEvents containsObject:type]) {
        [self.avidVideoListener recordAdVolumeChangeEvent:volume];
        [self.sentEvents addObject:type];
    }
}

- (void)recordAdDurationChangeEvent:(NSString *)adDuration adRemainingTime:(NSString *)adRemainingTime {
    NSString *type = LoopMeIASEvents.adDurationChange;
    if (![self.sentEvents containsObject:type]) {
        [self.avidVideoListener recordAdDurationChangeEvent:adDuration adRemainingTime:adRemainingTime];
        [self.sentEvents addObject:type];
    }
}

- (void)recordEvent:(NSString *)type {
    if (!type) {
        return;
    }
    if (![self.sentEvents containsObject:type]) {
        SEL selector = NSSelectorFromString(type);
        if ([self.avidVideoListener respondsToSelector:selector]) {
            [self.avidVideoListener performSelector:selector];
        }
        [self.sentEvents addObject:type];
    }
}

- (void)clean {
    self.ready = NO;
    [self.sentEvents removeAllObjects];
}

@end
