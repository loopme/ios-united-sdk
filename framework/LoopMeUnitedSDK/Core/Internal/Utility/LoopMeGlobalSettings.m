//
//  LoopMeGlobalSettings.m
//  LoopMeSDK
//
//  Created by Kogda Bogdan on 6/16/15.
//
//

#import "LoopMeGlobalSettings.h"
#import <UIKit/UIKit.h>
#import <LoopMeUnitedSDK/LoopMeUnitedSDK-Swift.h>

@implementation LoopMeGlobalSettings

+ (instancetype)sharedInstance {
    static LoopMeGlobalSettings *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LoopMeGlobalSettings alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.userAgent = [UserAgent defaultUserAgent];
    }
    return self;
}

@end
