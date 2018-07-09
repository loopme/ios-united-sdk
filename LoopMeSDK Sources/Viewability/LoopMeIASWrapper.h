//
//  LoopMeDVSDKWrapper.h
//  LoopMeSDK
//
//  Created by Bohdan on 12/15/16.
//  Copyright © 2016 LoopMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoopMe_Avid.h"
#import "LoopMeAdConfiguration.h"

@interface LoopMeIASWrapper : NSObject <LoopMe_AvidVideoPlaybackListener>

@property(nonatomic, readonly) NSString *avidAdSessionId;

- (void)initWithPartnerVersion:(NSString *)version creativeType:(LoopMeCreativeType)creativeType adConfiguration:(LoopMeAdConfiguration *)configuration;

- (void)registerAdView:(UIView *)view;
- (void)unregisterAdView:(UIView *)view;
- (void)endSession;
- (void)registerFriendlyObstruction:(UIView *)friendlyObstruction;
- (void)recordReadyEvent;

- (void)clean;

@end
