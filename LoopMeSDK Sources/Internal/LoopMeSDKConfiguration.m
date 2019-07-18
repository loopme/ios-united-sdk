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

- (void)setUserConsent:(NSString *)consent {
    [[LoopMeGDPRTools sharedInstance] setCustomUserConsent:consent];
}

@end
