//
//  LoopMeGDPRAPIService.h
//  LoopMeSDK
//
//  Created by Bohdan on 4/27/18.
//  Copyright © 2018 LoopMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoopMeGDPRTools.h"

@interface LoopMeGDPRAPIService : NSObject

+ (BOOL)isNeedUserConsent:(NSString *)deviceID;
+ (BOOL)userConsent:(NSString *)deviceID consentType:(LoopMeConsentType *)consentType;
+ (NSURL *)consentURL:(NSString *)deviceID;

@end
