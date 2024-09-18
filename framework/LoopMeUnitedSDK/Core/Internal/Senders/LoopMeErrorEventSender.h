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
    LoopMeEventErrorTypeLatency,
};

@interface LoopMeErrorEventSender : NSObject

+ (NSString * _Nonnull)errorTypeToString: (LoopMeEventErrorType)errorType;

+ (void)sendError: (LoopMeEventErrorType)errorType
     errorMessage: (NSString * _Nonnull)errorMessage
             info: (NSDictionary<NSString *, NSString *>  * _Nonnull)info;

+  (void)sendError: (LoopMeEventErrorType)errorType
      errorMessage: (NSString * _Nonnull)errorMessage
            appkey: (NSString * _Nonnull)appkey;

+ (void)sendLetancyError: (LoopMeEventErrorType)errorType
       errorMessage: (NSString * _Nonnull)errorMessage
                  status: (NSString * _Nonnull)status
                    time: (NSInteger)timeElapsed
                   className: (NSString * _Nonnull)className;
@end
