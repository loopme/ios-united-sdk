//
//  LoopMeSDKConfiguration.m
//  Tester
//
//  Created by Bohdan on 5/14/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

#import "LoopMeSDKConfiguration.h"
#import "LoopMeGDPRTools.h"

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

@end
