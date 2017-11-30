//
//  LoopMeVASTEventSender.h
//  NewTestApp
//
//  Copyright © 2016 LoopMe. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    LoopMeVASTEventTypeImpression,
    LoopMeVASTEventTypeLinearStart,
    LoopMeVASTEventTypeLinearFirstQuartile,
    LoopMeVASTEventTypeLinearMidpoint,
    LoopMeVASTEventTypeLinearThirdQuartile,
    LoopMeVASTEventTypeLinearComplete,
    LoopMeVASTEventTypeLinearClose,
    LoopMeVASTEventTypeLinearPause,
    LoopMeVASTEventTypeLinearResume,
    LoopMeVASTEventTypeLinearExpand,
    LoopMeVASTEventTypeLinearCollapse,
    LoopMeVASTEventTypeLinearSkip,
    LoopMeVASTEventTypeLinearMute,
    LoopMeVASTEventTypeLinearUnmute,
    LoopMeVASTEventTypeLinearProgress,
    LoopMeVASTEventTypeLinearClickTracking,
    LoopMeVASTEventTypeLinearCreativeView,
    LoopMeVASTEventTypeCompanionCreativeView,
    LoopMeVASTEventTypeCompanionClickTracking,
} LoopMeVASTEventType;

@class LoopMeVASTTrackingLinks;
@interface LoopMeVASTEventTracker : NSObject

- (instancetype)initWithTrackingLinks:(LoopMeVASTTrackingLinks *)trackingLinks;
- (void)trackEvent:(LoopMeVASTEventType)type;
- (void)trackError:(NSInteger)code;

- (void)setCurrentTime:(double)currentTime;

@end
