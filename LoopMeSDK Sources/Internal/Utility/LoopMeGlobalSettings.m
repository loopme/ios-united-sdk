//
//  LoopMeGlobalSettings.m
//  LoopMeSDK
//
//  Created by Kogda Bogdan on 6/16/15.
//
//

#import "LoopMeGlobalSettings.h"

@implementation LoopMeGlobalSettings

+ (instancetype)sharedInstance {
    static LoopMeGlobalSettings *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LoopMeGlobalSettings alloc] init];
    });
    return instance;
}

@end
