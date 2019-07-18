//
//  LoopMeOMIDVideoEventsWrapper.h
//  Tester
//
//  Created by Bohdan on 2/21/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OMSDK_Loopme/OMIDImports.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoopMeOMIDVideoEventsWrapper : NSObject

- (nullable instancetype)initWithAdSession:(nonnull OMIDLoopmeAdSession *)session error:(NSError *_Nullable *_Nullable)error;

- (void)loadedWithVastProperties:(nonnull OMIDLoopmeVASTProperties *)vastProperties;

- (void)startWithDuration:(CGFloat)duration
        videoPlayerVolume:(CGFloat)videoPlayerVolume;

- (void)firstQuartile;

- (void)midpoint;

- (void)thirdQuartile;

- (void)complete;

- (void)pause;

- (void)resume;

- (void)skipped;

- (void)volumeChangeTo:(CGFloat)playerVolume;

- (void)adUserInteractionWithType:(OMIDInteractionType)interactionType
NS_SWIFT_NAME(adUserInteraction(withType:));

@end

NS_ASSUME_NONNULL_END
