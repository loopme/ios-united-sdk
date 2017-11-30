//
//  LoopMeVastLinks.h
//
//  Copyright © 2016 LoopMe. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LoopMeVastLinearTrackingLinks;
@class LoopMeVastCompanionAdsTrackingLinks;

@interface LoopMeVASTTrackingLinks : NSObject

@property (nonatomic) NSMutableSet *errorLinkTemplates;
@property (nonatomic) NSMutableSet *impressionLinks;
@property (nonatomic) NSString *clickThroughCompanion;
@property (nonatomic) NSString *clickThroughVideo;
@property (nonatomic) LoopMeVastLinearTrackingLinks *linearTrackingLinks;
@property (nonatomic) LoopMeVastCompanionAdsTrackingLinks *companionTrackingLinks;

@end

@interface LoopMeVastLinearTrackingLinks : NSObject

@property (nonatomic) NSMutableSet *creativeView;
@property (nonatomic) NSMutableSet *start;
@property (nonatomic) NSMutableSet *firstQuartile;
@property (nonatomic) NSMutableSet *midpoint;
@property (nonatomic) NSMutableSet *thirdQuartile;
@property (nonatomic) NSMutableSet *complete;
@property (nonatomic) NSMutableSet *closeLinear;
@property (nonatomic) NSMutableSet *pause;
@property (nonatomic) NSMutableSet *resume;
@property (nonatomic) NSMutableSet *skip;
@property (nonatomic) NSMutableSet *mute;
@property (nonatomic) NSMutableSet *unmute;
@property (nonatomic) NSMutableSet *progress;
@property (nonatomic) NSMutableSet *expand;
@property (nonatomic) NSMutableSet *collapse;
@property (nonatomic) NSMutableSet *clickTracking;

- (void)add:(LoopMeVastLinearTrackingLinks *)links;

@end

@interface LoopMeVastCompanionAdsTrackingLinks : NSObject

@property (nonatomic) NSMutableSet *creativeView;
@property (nonatomic) NSMutableSet *clickTracking;

- (void)add:(LoopMeVastCompanionAdsTrackingLinks *)links;

@end
