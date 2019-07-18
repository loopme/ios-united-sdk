//
//  LoopMeSDKConfiguration.h
//  Tester
//
//  Created by Bohdan on 5/14/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoopMeSDKConfiguration : NSObject

/**
 * Set YES if you want to disable loading video when Wi-Fi turned off. Default value NO.
 */
@property (nonatomic, assign, getter = isDoNotLoadVideoWithoutWiFi) BOOL doNotLoadVideoWithoutWiFi;

+ (instancetype)defaultConfiguration;

/**
 * Consent string in known (https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/Consent%20string%20and%20vendor%20list%20formats%20v1.1%20Final.md#vendor-consent-string-format)
 */
- (void)setUserConsent:(NSString *)consent;

@end

NS_ASSUME_NONNULL_END
