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

@class LoopMeOMIDWrapper;

@interface LoopMeSDK ()

@property (nonatomic) BOOL isReady;
@property (nonatomic, strong) NSDate *startSessionTime;
@property (nonatomic, strong) NSMutableDictionary *sessionDepth;
@property (nonatomic, strong) NSMutableDictionary *resourcesFiles;
@property (nonatomic, strong) NSString *adpaterName;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *sdkInitTimes;
@property (nonatomic, strong) NSString *sessionId;

@end

@implementation LoopMeSDK

+ (instancetype)shared {
    static LoopMeSDK *instance;
    
    if (!instance) {
        instance = [[LoopMeSDK alloc] init];
        instance.sessionDepth = [[NSMutableDictionary alloc] init];
        instance.resourcesFiles = [[NSMutableDictionary alloc] init];
        instance.sdkInitTimes = [[NSMutableArray alloc] init];
    }
    
    return instance;
}

- (void)setSdkInitTime:(NSUInteger)value {
    [self.sdkInitTimes addObject: @(value)];
}

- (NSUInteger)getSdkInitTime {
    if ([self.sdkInitTimes count] == 0) return 0;
    NSNumber *lastValue = [self.sdkInitTimes lastObject];
    [self.sdkInitTimes removeLastObject];
    return [lastValue unsignedIntegerValue];
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
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    
    if (self.isReady) {
        [self setSdkInitTime: (int)((CFAbsoluteTimeGetCurrent() - startTime) * 1000.0)];
        if (completionBlock != nil) {
            completionBlock(YES, nil);
        }
        return;
    }
    self.isReady = YES;
    
    [[LoopMeGDPRTools sharedInstance] prepareConsent];
    [LoopMeGlobalSettings sharedInstance];

    // Initialize the start for session duration time here
    [[LoopMeLifecycleManager shared] startSession];

    CFAbsoluteTime startTimeOmid = CFAbsoluteTimeGetCurrent();
    (void)[LoopMeOMIDWrapper initOMIDWithCompletionBlock: ^(BOOL ready) {
        CFAbsoluteTime endTimeOmid  = CFAbsoluteTimeGetCurrent();
        double timeElapsedOmid = endTimeOmid - startTimeOmid;
        if (timeElapsedOmid > 0.1) {
            NSMutableDictionary *infoDictionary = [[NSMutableDictionary alloc] init];
            [infoDictionary setObject:@"LoopMeSDK" forKey: kErrorInfoClass];;
            [infoDictionary setObject:@((int)(timeElapsedOmid *1000)) forKey: kErrorInfoTimeout];;

            [LoopMeErrorEventSender sendError: LoopMeEventErrorTypeLatency
                                 errorMessage: @"Omid init time alert <100ms"
                                         info: infoDictionary];
        }
        NSLog(@"%@", LoopMeOMIDWrapper.isReady ? @"LoopMe OMID initialized" : @"LoopMe OMID not initialized");
    }];
    
    if (completionBlock != nil) {
        completionBlock(YES, nil);
    }
    
    CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
    double timeElapsed = endTime - startTime;
    [self setSdkInitTime: (int)(timeElapsed * 1000.0)];

     if (timeElapsed > 0.1) {
         NSMutableDictionary *infoDictionary = [[NSMutableDictionary alloc] init];
         [infoDictionary setObject:@"LoopMeSDK" forKey: kErrorInfoClass];;
         [infoDictionary setObject: @((int)(timeElapsed *1000)) forKey: kErrorInfoTimeout];;

         [LoopMeErrorEventSender sendError: LoopMeEventErrorTypeLatency
                              errorMessage: @"SDK Init time alert <100ms"
                                      info: infoDictionary];
     }
}

-(void)setAdapterName: (NSString* )name {
    self.adpaterName = name;
}

-(NSString *)adapterName {
    return self.adpaterName;;
}

- (NSString *)getJSStringFromResources: (NSString *)fileName {
    NSBundle *resourcesBundle = [LoopMeSDK resourcesBundle];
    NSString *fileContent = [self.resourcesFiles valueForKey:fileName];
    
    if (fileContent) return fileContent;
    NSString *jsPath = [resourcesBundle pathForResource:fileName ofType:@"ignore"];
    fileContent = [NSString stringWithContentsOfFile: jsPath encoding: NSUTF8StringEncoding error: NULL];
    if (fileContent) {
        [self.resourcesFiles setValue:fileContent forKey:fileName];
        return fileContent;
    }
    NSLog(@"Error: File not found in resourcesBundle for fileName: %@", fileName);
    return nil;
}

@end
