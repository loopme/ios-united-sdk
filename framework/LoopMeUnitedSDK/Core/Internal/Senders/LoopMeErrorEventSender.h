//
//  LoopMeErrorSender.h
//  LoopMeSDK
//
//  Created by Bohdan on 12/11/15.
//  Copyright © 2015 LoopMe. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, LoopMeEventErrorType) {
    LoopMeEventErrorTypeServer,
    LoopMeEventErrorTypeBadAsset,
    LoopMeEventErrorTypeJS,
    LoopMeEventErrorTypeCustom,
};

@interface LoopMeErrorEventSender : NSObject

+ (NSString * _Nonnull)errorTypeToString: (LoopMeEventErrorType)errorType;

+ (void)sendError: (LoopMeEventErrorType)errorType
     errorMessage: (NSString * _Nonnull)errorMessage
           appkey: (NSString * _Nonnull)appkey;

+ (void)sendError: (LoopMeEventErrorType)errorType
     errorMessage: (NSString * _Nonnull)errorMessage
           appkey: (NSString * _Nonnull)appkey
             info: (NSArray<NSString *> * _Nonnull)info;

@end
