//
//  AbstractAvidAdSession.h
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 05/04/16.
//  Copyright © 2016 Integral. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoopMe_AvidDeferredAdSessionListener.h"

@class UIView;

@interface LoopMe_AbstractAvidAdSession : NSObject

@property(nonatomic, readonly) NSString *avidAdSessionId;
@property(nonatomic, readonly) id<LoopMe_AvidDeferredAdSessionListener> avidDeferredAdSessionListener;

- (void)registerAdView:(UIView *)view;
- (void)unregisterAdView:(UIView *)view;
- (void)endSession;
- (void)registerFriendlyObstruction:(UIView *)friendlyObstruction;

@end
