//
//  LoopMeErrorSender.h
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

+ (void)sendError:(LoopMeEventErrorType)errorType
     errorMessage:(NSString *)errorMessage appkey:(NSString *)appkey;

@end
