//
//  LoopMeSDKConfiguration.m
//  Tester
//
//  Created by Bohdan on 5/14/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

#import "LoopMeSDKConfiguration.h"
#import "LoopMeGDPRTools.h"
#import <LoopMeUnitedSDK/LoopMeUnitedSDK-Swift.h>

@implementation LoopMeSDKConfiguration

+ (instancetype)defaultConfiguration {
    return [[LoopMeSDKConfiguration alloc] init];
}

- (void)setUserConsent:(BOOL)consent {
    [[LoopMeGDPRTools sharedInstance] setCustomUserConsent:consent];
}

- (void)setUserConsentString:(NSString *)consent {
    [[LoopMeGDPRTools sharedInstance] setUserConsentString:consent];
}

- (void)setCCPA:(NSString *)ccpa{
    [LoopMeCCPATools setCcpaString:ccpa];
}

- (void)setCOPPA:(BOOL)coppa{
    [LoopMeCOPPATools setCoppa:coppa];
}

@end
