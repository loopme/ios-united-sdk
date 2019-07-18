//
//  LoopMeVastLinks.h
//
//  Copyright © 2016 LoopMe. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LoopMeVastLinearTrackingLinks;
@class LoopMeVastCompanionAdsTrackingLinks;
@class LoopMeVASTViewableImpression;

@interface LoopMeVASTTrackingLinks : NSObject

@property (nonatomic) NSMutableSet *errorLinkTemplates;
@property (nonatomic) NSMutableSet *adVerificationErrorLinkTemplates;
@property (nonatomic) NSMutableSet *impressionLinks;
@property (nonatomic) NSString *clickThroughCompanion;
@property (nonatomic) NSString *clickThroughVideo;
@property (nonatomic) LoopMeVastLinearTrackingLinks *linearTrackingLinks;
@property (nonatomic) LoopMeVASTViewableImpression *viewableImpression;
@property (nonatomic) LoopMeVastCompanionAdsTrackingLinks *companionTrackingLinks;

@property (nonatomic) NSArray *adVerification;

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

@interface LoopMeVASTViewableImpression : NSObject

@property (nonatomic) NSMutableSet *viewable;
@property (nonatomic) NSMutableSet *notViewable;
@property (nonatomic) NSMutableSet *viewUndetermined;

- (void)add:(LoopMeVASTViewableImpression *)links;

@end

@interface LoopMeVerification : NSObject

@property (nonatomic, strong) NSString *vendorKey;
@property (nonatomic, strong) NSString *resource;
@property (nonatomic, strong) NSString *params;

@end
