//
//  LoopMeOMIDVideoEventsWrapper.m
//  Tester
//
//  Created by Bohdan on 2/21/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

#import "LoopMeOMIDVideoEventsWrapper.h"

extern const struct LoopMeOMIDVideoEventsStruct {
    __unsafe_unretained NSString *adStarted;
    __unsafe_unretained NSString *adLoaded;;
    __unsafe_unretained NSString *adComplete;
    __unsafe_unretained NSString *adVideoFirstQuartile;
    __unsafe_unretained NSString *adVideoMidpoint;
    __unsafe_unretained NSString *adVideoThirdQuartile;
    __unsafe_unretained NSString *adPaused;
    __unsafe_unretained NSString *adExpandedChange;
    __unsafe_unretained NSString *adResume;
    __unsafe_unretained NSString *adSkipped;
    __unsafe_unretained NSString *adVolumeChangeEvent;
    
} LoopMeOMIDVideoEventsValues;

const struct LoopMeOMIDVideoEventsStruct LoopMeOMIDVideoEventsValues =
{
    .adStarted = @"recordAdStartedEvent",
    .adLoaded = @"recordAdLoadedEvent",
    .adComplete = @"recordAdCompleteEvent",
    .adVideoFirstQuartile = @"recordAdVideoFirstQuartileEvent",
    .adVideoMidpoint = @"recordAdVideoMidpointEvent",
    .adVideoThirdQuartile = @"recordAdVideoThirdQuartileEvent",
    .adPaused = @"recordAdPausedEvent",
    .adExpandedChange = @"recordAdExpandedChangeEvent",
    .adResume = @"recordAdResume",
    .adSkipped = @"recordAdSkippedEvent",
    .adVolumeChangeEvent = @"recordAdVolumeChangeEvent:",
};


@interface LoopMeOMIDVideoEventsWrapper()

@property (nonatomic, strong) NSMutableSet *sentEvents;
@property (nonatomic, strong) OMIDLoopmeMediaEvents *videoEvents;

@end

@implementation LoopMeOMIDVideoEventsWrapper

- (instancetype)initWithAdSession:(OMIDLoopmeAdSession *)session error:(NSError **)error {
    
    if (self = [super init]) {
        _sentEvents = [NSMutableSet new];
        self.videoEvents = [[OMIDLoopmeMediaEvents alloc] initWithAdSession:session error:error];
    }
    return self;
}

- (void)loadedWithVastProperties:(nonnull OMIDLoopmeVASTProperties *)vastProperties {
    if (![self.sentEvents containsObject:LoopMeOMIDVideoEventsValues.adLoaded]) {
        [self.sentEvents addObject:LoopMeOMIDVideoEventsValues.adLoaded];
        [self.videoEvents loadedWithVastProperties:vastProperties];
    }
    
}

- (void)startWithDuration:(CGFloat)duration
        videoPlayerVolume:(CGFloat)videoPlayerVolume {
    if (![self.sentEvents containsObject:LoopMeOMIDVideoEventsValues.adStarted]) {
        [self.sentEvents addObject:LoopMeOMIDVideoEventsValues.adStarted];
        [self.videoEvents startWithDuration:duration mediaPlayerVolume:videoPlayerVolume];
    }
}

- (void)firstQuartile {
    if (![self.sentEvents containsObject:LoopMeOMIDVideoEventsValues.adVideoFirstQuartile]) {
        [self.sentEvents addObject:LoopMeOMIDVideoEventsValues.adVideoFirstQuartile];
        [self.videoEvents firstQuartile];
    }
}

- (void)midpoint {
    if (![self.sentEvents containsObject:LoopMeOMIDVideoEventsValues.adVideoMidpoint]) {
        [self.sentEvents addObject:LoopMeOMIDVideoEventsValues.adVideoMidpoint];
        [self.videoEvents midpoint];
    }
}

- (void)thirdQuartile {
    if (![self.sentEvents containsObject:LoopMeOMIDVideoEventsValues.adVideoThirdQuartile]) {
        [self.sentEvents addObject:LoopMeOMIDVideoEventsValues.adVideoThirdQuartile];
        [self.videoEvents thirdQuartile];
    }
    
}

- (void)complete {
    if (![self.sentEvents containsObject:LoopMeOMIDVideoEventsValues.adComplete]) {
        [self.sentEvents addObject:LoopMeOMIDVideoEventsValues.adComplete];
        [self.videoEvents complete];
    }
}

- (void)pause {
    if ([self.sentEvents containsObject:LoopMeOMIDVideoEventsValues.adStarted]) {
        [self.videoEvents pause];
    }
}

- (void)resume {
    [self.videoEvents resume];
}

- (void)skipped {
    if (![self.sentEvents containsObject:LoopMeOMIDVideoEventsValues.adSkipped]) {
        [self.sentEvents addObject:LoopMeOMIDVideoEventsValues.adSkipped];
        [self.videoEvents skipped];
    }
}

- (void)volumeChangeTo:(CGFloat)playerVolume {
    [self.videoEvents volumeChangeTo:playerVolume];
}

- (void)adUserInteractionWithType:(OMIDInteractionType)interactionType
NS_SWIFT_NAME(adUserInteraction(withType:)) {
    
    [self.videoEvents adUserInteractionWithType:interactionType];
}

@end
