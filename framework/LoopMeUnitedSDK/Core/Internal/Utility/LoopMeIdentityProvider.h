//
//  LoopMeIdentityProvider.h
//  LoopMeSDK
//
//  Created by Dmitriy Lihachov on 11/11/13.
//  Copyright (c) 2013 LoopMe. All rights reserved.
//

@interface LoopMeIdentityProvider : NSObject

+ (BOOL)advertisingTrackingEnabled;
+ (BOOL)appTrackingTransparencyEnabled;
+ (NSNumber *)customAuthorizationStatus;
+ (NSString *)advertisingTrackingDeviceIdentifier;
+ (NSString *)deviceModel;
+ (NSString *)deviceType;
+ (NSUInteger)deviceTypeNum;
+ (NSString *)phoneName;

@end
