//
//  LoopMeError.h
//  LoopMeSDK
//
//  Created by Kogda Bogdan on 2/18/15.
//
//

#import <Foundation/Foundation.h>

#define kLoopMeErrorDomain @"loopme.me"

@interface LoopMeError : NSObject

+ (NSError *)errorForStatusCode:(NSInteger)statusCode;

@end

typedef NS_ENUM(NSInteger, LoopMeErrorCode) {
    LoopMeErrorCodeNoAdsFound = 204,
    LoopMeErrorCodeInvalidAppKey = 404,
    LoopMeErrorCodeVideoDownloadTimeout = 408,
    LoopMeErrorCodeIncorrectResponse = -10,
    LoopMeErrorCodeSpecificHost = -12,
    LoopMeErrorCodeHTMLRequestTimeOut = -13,
    LoopMeErrorCodeURLResolve = -20,
    LoopMeErrorCodeWrirtingToDisk = -21,
    LoopMeErrorCodeCanNotLoadVideo = -22,
    LoopMeErrorCodeNoResourceBundle = -23,
    LoopMeErrorCodeInvalidRequest = -24
};
