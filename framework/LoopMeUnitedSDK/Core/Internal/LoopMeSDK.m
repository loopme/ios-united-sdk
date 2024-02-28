//
//  LoopMeSDK.m
//  Demo
//
//  Created by Bohdan on 4/17/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

#import "LoopMeSDK.h"
#import "LoopMeOMIDWrapper.h"
#import "LoopMeGlobalSettings.h"
#import "LoopMeGDPRTools.h"
#import "LoopMeErrorEventSender.h"
#import "LoopMeDefinitions.h"

@interface LoopMeSDK ()

@property (nonatomic) BOOL isReady;

@end

@implementation LoopMeSDK

+ (instancetype)shared {
    static LoopMeSDK *instance;
    
    if (!instance) {
        instance = [[LoopMeSDK alloc] init];
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
        if ([bundle pathForResource:@"LoopMeResources" ofType:@"bundle"]) {
            NSURL *bundleURL = [bundle URLForResource:@"LoopMeResources" withExtension:@"bundle"];
            _resourcesBundle = [NSBundle bundleWithURL:bundleURL];
            return _resourcesBundle;
        }
    }
    if (!bundlePath) {
        @throw [NSException exceptionWithName:@"NoBundleResource" reason:@"No loopme resource bundle" userInfo:nil];
    }
    _resourcesBundle = [NSBundle bundleWithPath:bundlePath];
    return _resourcesBundle;
    
}

+ (NSString *)version {
    return LOOPME_SDK_VERSION;
}

- (void)initSDKFromRootViewController:(UIViewController *)rootViewController
                     sdkConfiguration:(LoopMeSDKConfiguration *)configuration
                     completionBlock :(void(^_Nullable)(BOOL, NSError *))completionBlock {
    
    if (self.isReady) {
        return;
    }
    
    if (SYSTEM_VERSION_LESS_THAN(@"10.0")) {
        NSString *description = @"Block iOS versions less then 10.0";
        NSError *error = [NSError errorWithDomain:@"loopme.com" code:0 userInfo:@{ NSLocalizedDescriptionKey : description }];
        if (completionBlock != nil) {
            completionBlock(false, error);
        }
        return;
    }
    
    if (@available(iOS 14, *)) {
          ATTrackingManagerAuthorizationStatus status = [ATTrackingManager trackingAuthorizationStatus];

          if (status == ATTrackingManagerAuthorizationStatusNotDetermined) {
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                  [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status){}];
              });
          }
    }
    
    [[LoopMeGDPRTools sharedInstance] showGDPRWindowFromViewController:rootViewController];
    [LoopMeGlobalSettings sharedInstance];
    [LoopMeOMIDWrapper initOMIDWithCompletionBlock:^(BOOL ready) {
        if (self.isReady && ready) {
            return;
        }
        self.isReady = ready;
        NSError *error;
        NSString *description = @"LoopMe OMID fail to initialize";
        if (!ready) {
            [LoopMeErrorEventSender sendError:LoopMeEventErrorTypeServer errorMessage:description appkey:@"unknown"];
            error = [NSError errorWithDomain:@"loopme.com" code:-1 userInfo:@{NSLocalizedDescriptionKey : description}];
        }
        
        if (completionBlock != nil) {
            completionBlock(ready, error);
        }
    }];
    
}

- (void)initSDKFromRootViewController:(UIViewController *)rootViewController
                      completionBlock:(void (^)(BOOL, NSError *))completionBlock {
    
    LoopMeSDKConfiguration *configuration = [LoopMeSDKConfiguration defaultConfiguration];
    [self initSDKFromRootViewController:rootViewController sdkConfiguration:configuration completionBlock:completionBlock];
}

@end
