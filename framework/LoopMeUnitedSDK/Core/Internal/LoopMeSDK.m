//
//  LoopMeSDK.m
//  Demo
//
//  Created by Bohdan on 4/17/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

#import "LoopMeSDK.h"
#import "LoopMeGlobalSettings.h"
#import "LoopMeGDPRTools.h"
#import "LoopMeErrorEventSender.h"
#import "LoopMeDefinitions.h"
#import <LoopMeUnitedSDK/LoopMeUnitedSDK-Swift.h>

@interface LoopMeSDK ()

@property (nonatomic) BOOL isReady;
@property (nonatomic, strong) NSDate *startSessionTime;
@property (nonatomic, strong) NSMutableDictionary *sessionDepth;
@property (nonatomic, strong) NSString *adpaterName;

@end

@implementation LoopMeSDK

+ (instancetype)shared {
    static LoopMeSDK *instance;
    
    if (!instance) {
        instance = [[LoopMeSDK alloc] init];
        instance.sessionDepth = [[NSMutableDictionary alloc] init];
    }
    
    return instance;
}

+ (NSBundle * )resourcesBundle {
    
    static NSBundle *_resourcesBundle;
    
    if (_resourcesBundle) {
        return  _resourcesBundle;
    }
    NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"LoopMeResources" withExtension:@"bundle"];
    if (bundleURL) {
        _resourcesBundle = [NSBundle bundleWithURL:bundleURL];
        return _resourcesBundle;
    }
    
    NSString *bundlePath = nil;
    NSArray *allBundles = [NSBundle allFrameworks];
    for (NSBundle *bundle in allBundles) {
        if ([bundle pathForResource: @"LoopMeResources" ofType: @"bundle"]) {
            NSURL *bundleURL = [bundle URLForResource: @"LoopMeResources" withExtension: @"bundle"];
            _resourcesBundle = [NSBundle bundleWithURL: bundleURL];
            return _resourcesBundle;
        }
    }
    if (!bundlePath) {
        @throw [NSException exceptionWithName: @"NoBundleResource" reason: @"No loopme resource bundle" userInfo: nil];
    }
    _resourcesBundle = [NSBundle bundleWithPath: bundlePath];
    return _resourcesBundle;
    
}

+ (NSString *)version {
    return LOOPME_SDK_VERSION;
}

/// TODO: Remove and use `init` instead of `initSDKFromRootViewController`
- (void)initSDKFromRootViewController: (UIViewController *)rootViewController
                     sdkConfiguration: (LoopMeSDKConfiguration *) configuration
                      completionBlock: (void(^_Nullable)(BOOL, NSError * _Nullable))completionBlock __attribute__((deprecated("Use init:sdkConfiguration:completionBlock instead"))) {
    [self init: configuration completionBlock: completionBlock];
}

/// TODO: Remove and use `init` instead of `initSDKFromRootViewController`
- (void)initSDKFromRootViewController: (UIViewController *)rootViewController
                      completionBlock: (void(^_Nullable)(BOOL, NSError * _Nullable))completionBlock __attribute__((deprecated("Use init:completionBlock instead"))) {
    [self init: completionBlock];
}

- (void)init: (void(^_Nullable)(BOOL, NSError *))completionBlock {
    [self init: [LoopMeSDKConfiguration defaultConfiguration] completionBlock: completionBlock];
}

- (void)init: (LoopMeSDKConfiguration *)configuration completionBlock: (void(^_Nullable)(BOOL, NSError *))completionBlock {
    if (self.isReady) {
        return;
    }
    
    [[LoopMeGDPRTools sharedInstance] prepareConsent];
    [LoopMeGlobalSettings sharedInstance];
    self.isReady = YES;
    
    // Initialize the start for session duration time here
    [self startSession];

    completionBlock(YES, nil);
}

- (NSNumber *)timeElapsedSinceStart {
    if (self.startSessionTime) {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.startSessionTime];
        return @(round(timeInterval));
    }
    return @0;
}

-(void)startSession {
    if (!self.startSessionTime) {
        self.startSessionTime = [NSDate date];
    }
}

-(void)updateSessionDepth: (NSString* )appKey {
    NSNumber* count = [self.sessionDepth valueForKey:appKey];
    NSNumber* value = count ? [NSNumber numberWithInt: count.intValue + 1] : [NSNumber numberWithInt: 1];
    [self.sessionDepth setValue: value  forKey: appKey];
}

- (NSNumber *)sessionDepthForAppKey:(NSString *)appKey {
    NSNumber *depth = [self.sessionDepth valueForKey: appKey];
    
    return depth ?: @0;
}

-(void)setAdapterName: (NSString* )name {
    self.adpaterName = name;
}

-(NSString *)adapterName {
    return self.adpaterName;;
}

@end
