//
//  LoopMeDVSDKWrapper.h
//  LoopMeSDK
//
//  Created by Bohdan on 12/15/16.
//  Copyright © 2016 LoopMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LoopMeUnitedSDK/LoopMeUnitedSDK-Swift.h>

#import "LoopMe_Avid.h"

@class LoopMeAdConfiguration;

@interface LoopMeIASWrapper : NSObject <LoopMe_AvidVideoPlaybackListener>

@property(nonatomic, readonly) NSString *avidAdSessionId;

- (void)initWithPartnerVersion:(NSString *)version creativeType:(NSInteger)creativeType adConfiguration:(LoopMeAdConfiguration *)configuration;

- (void)registerAdView:(UIView *)view;
- (void)unregisterAdView:(UIView *)view;
- (void)endSession;
- (void)registerFriendlyObstruction:(UIView *)friendlyObstruction;
- (void)recordReadyEvent;

- (void)clean;

@end
