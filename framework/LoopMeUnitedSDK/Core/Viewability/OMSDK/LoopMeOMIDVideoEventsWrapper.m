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
@property (nonatomic, strong) OMIDLoopmeAdEvents *videoEvents;
@property (nonatomic, strong) OMIDLoopmeMediaEvents *mediaEvents;

@end

@implementation LoopMeOMIDVideoEventsWrapper

- (instancetype)initWithAdSession:(OMIDLoopmeAdSession *)session error:(NSError **)error {
    
    if (self = [super init]) {
        _sentEvents = [NSMutableSet new];
        self.videoEvents = [[OMIDLoopmeAdEvents alloc] initWithAdSession:session error:error];
        self.mediaEvents = [[OMIDLoopmeMediaEvents alloc] initWithAdSession:session error:error];

    }
    return self;
}

- (void)loadedWithVastProperties:(nonnull OMIDLoopmeVASTProperties *)vastProperties {
    if (![self.sentEvents containsObject:LoopMeOMIDVideoEventsValues.adLoaded]) {
        [self.sentEvents addObject:LoopMeOMIDVideoEventsValues.adLoaded];
        NSError *aErr;
        [self.videoEvents loadedWithVastProperties:vastProperties error: &aErr];
    }
    
}

- (void)startWithDuration:(CGFloat)duration
        videoPlayerVolume:(CGFloat)videoPlayerVolume {
    if (![self.sentEvents containsObject:LoopMeOMIDVideoEventsValues.adStarted]) {
        [self.sentEvents addObject:LoopMeOMIDVideoEventsValues.adStarted];
        [self.mediaEvents startWithDuration:duration mediaPlayerVolume:videoPlayerVolume];
    }
}

- (void)firstQuartile {
    if (![self.sentEvents containsObject:LoopMeOMIDVideoEventsValues.adVideoFirstQuartile]) {
        [self.sentEvents addObject:LoopMeOMIDVideoEventsValues.adVideoFirstQuartile];
        [self.mediaEvents firstQuartile];
    }
}

- (void)midpoint {
    if (![self.sentEvents containsObject:LoopMeOMIDVideoEventsValues.adVideoMidpoint]) {
        [self.sentEvents addObject:LoopMeOMIDVideoEventsValues.adVideoMidpoint];
        [self.mediaEvents midpoint];
    }
}

- (void)thirdQuartile {
    if (![self.sentEvents containsObject:LoopMeOMIDVideoEventsValues.adVideoThirdQuartile]) {
        [self.sentEvents addObject:LoopMeOMIDVideoEventsValues.adVideoThirdQuartile];
        [self.mediaEvents thirdQuartile];
    }
    
}

- (void)complete {
    if (![self.sentEvents containsObject:LoopMeOMIDVideoEventsValues.adComplete]) {
        [self.sentEvents addObject:LoopMeOMIDVideoEventsValues.adComplete];
        [self.mediaEvents complete];
    }
}

- (void)pause {
    if ([self.sentEvents containsObject:LoopMeOMIDVideoEventsValues.adStarted]) {
        [self.mediaEvents pause];
    }
}

- (void)resume {
    [self.mediaEvents resume];
}

- (void)skipped {
    if (![self.sentEvents containsObject:LoopMeOMIDVideoEventsValues.adSkipped]) {
        [self.sentEvents addObject:LoopMeOMIDVideoEventsValues.adSkipped];
        [self.mediaEvents skipped];
    }
}

- (void)volumeChangeTo:(CGFloat)playerVolume {
    [self.mediaEvents volumeChangeTo:playerVolume];
}

- (void)adUserInteractionWithType:(OMIDInteractionType)interactionType
NS_SWIFT_NAME(adUserInteraction(withType:)) {
    
    [self.mediaEvents adUserInteractionWithType:interactionType];
}

@end
