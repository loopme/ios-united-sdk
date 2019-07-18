//
//  LoopMeGlobalSettings.h
//  LoopMeSDK
//
//  Created by Kogda Bogdan on 6/16/15.
//
//

#import <Foundation/Foundation.h>

static const NSString *kLoopMeAdvertiser = @"advertiser";
static const NSString *kLoopMeCampaign = @"campaign";
static const NSString *kLoopMeLineItem = @"lineitem";
static const NSString *kLoopMeCreative = @"id";
static const NSString *kLoopMeAPP = @"appname";
static const NSString *kLoopMeDeveloper = @"developer";
static const NSString *kLoopMeCompany = @"company";

@interface LoopMeGlobalSettings : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, assign, getter = isDoNotLoadVideoWithoutWiFi) BOOL doNotLoadVideoWithoutWiFi;
@property (nonatomic, assign, getter = isLiveDebugEnabled) BOOL liveDebugEnabled;
@property (nonatomic, strong) NSString *appKeyForLiveDebug;
@property (nonatomic, strong) NSMutableDictionary *adIds;
@property (nonatomic, strong) NSString *userAgent;

@end
