//
//  AvidAdSessionManager.h
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 05/04/16.
//  Copyright © 2016 Integral. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoopMe_AvidDisplayAdSession.h"
#import "LoopMe_AvidManagedDisplayAdSession.h"
#import "LoopMe_AvidVideoAdSession.h"
#import "LoopMe_AvidManagedVideoAdSession.h"
#import "LoopMe_ExternalAvidAdSessionContext.h"

@interface LoopMe_AvidAdSessionManager : NSObject

+ (NSString *)version;
+ (NSString *)releaseDate;

+ (LoopMe_AvidVideoAdSession *)startAvidVideoAdSessionWithContext:(LoopMe_ExternalAvidAdSessionContext *)avidAdSessionContext;
+ (LoopMe_AvidDisplayAdSession *)startAvidDisplayAdSessionWithContext:(LoopMe_ExternalAvidAdSessionContext *)avidAdSessionContext;
+ (LoopMe_AvidManagedVideoAdSession *)startAvidManagedVideoAdSessionWithContext:(LoopMe_ExternalAvidAdSessionContext *)avidAdSessionContext;
+ (LoopMe_AvidManagedDisplayAdSession *)startAvidManagedDisplayAdSessionWithContext:(LoopMe_ExternalAvidAdSessionContext *)avidAdSessionContext;

@end
