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
    Set if you know GDPR user consent in bool format
 */
- (void)setUserConsent:(BOOL)consent;

@end

NS_ASSUME_NONNULL_END
