//
//  LoopMeGlobalSettings.m
//  LoopMeSDK
//
//  Created by Kogda Bogdan on 6/16/15.
//
//

#import "LoopMeGlobalSettings.h"
#import <UIKit/UIKit.h>

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
        dispatch_async(dispatch_get_main_queue(), ^{
            self.userAgent = [[[UIWebView alloc] init] stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        });
    }
    return self;
}

@end
