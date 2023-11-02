//
//  OMSDKWrapper.h
//  Tester
//
//  Created by Bohdan on 1/23/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class OMIDLoopmeAdSession;

typedef NS_ENUM(NSUInteger, OMIDLoopmeCreativeType) {
    OMIDLoopmeCreativeTypeHTML,
    OMIDLoopmeCreativeTypeNativeVideo
};

@class OMIDLoopmeAdSessionContext;
@class LoopMeAdVerification;

@interface LoopMeOMIDWrapper : NSObject

+ (BOOL)initOMIDWithCompletionBlock:(void (^)(BOOL))completionBlock;

- (nullable NSString *)injectScriptContentIntoHTML:(nonnull NSString *)htmlString error:(NSError *_Nullable *_Nullable)error;
- (nullable OMIDLoopmeAdSession *)sessionForType:(OMIDLoopmeCreativeType)creativeType
                                       resources:(NSArray<LoopMeAdVerification *> * _Nullable)resources
                                webView:(UIView * _Nullable )webView
                                           error:(NSError *_Nullable *_Nullable) error;
@end

NS_ASSUME_NONNULL_END
