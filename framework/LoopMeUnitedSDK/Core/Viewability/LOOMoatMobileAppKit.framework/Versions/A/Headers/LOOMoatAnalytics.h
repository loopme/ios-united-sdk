//
//  LOOMoatAnalytics.h
//  LOOMoatMobileAppKit
//
//  Created by Moat on 6/2/16.
//  Copyright © 2016 Moat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <LOOMoatMobileAppKit/LOOMoatWebTracker.h>
#import <LOOMoatMobileAppKit/LOOMoatNativeDisplayTracker.h>
#import <LOOMoatMobileAppKit/LOOMoatVideoTracker.h>

@interface LOOMoatOptions : NSObject<NSCopying>

@property BOOL locationServicesEnabled;
@property BOOL debugLoggingEnabled;
@property BOOL IDFACollectionEnabled;

@end

@interface LOOMoatAnalytics : NSObject

+ (instancetype)sharedInstance;

- (void)start;

- (void)startWithOptions:(LOOMoatOptions *)options;

- (void)prepareNativeDisplayTracking:(NSString *)partnerCode;

@end
