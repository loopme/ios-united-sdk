//
//  LoopMeVPAIDError.h
//  LoopMeSDK
//
//  Copyright (c) 2016 LoopMe. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kLoopMeErrorDomain @"loopme.me"

@interface LoopMeVPAIDError : NSObject

+ (NSError *)errorForStatusCode:(NSInteger)statusCode;

@end

typedef NS_ENUM(NSInteger, LoopMeVPAIDErrorCode) {
    LoopMeVPAIDErrorCodeXMLParsingFailed = 100,
    LoopMeVPAIDErrorCodeTrafficking = 200,
    LoopMeVPAIDErrorCodeWrapperError = 300,
    LoopMeVPAIDErrorCodeWrapperTimeOut = 301,
    LoopMeVPAIDErrorCodeWrapperLimit = 302,
    LoopMeVPAIDErrorCodeWrapperNoVAST = 303,
    LoopMeVPAIDErrorCodeMediaNotFound = 401,
    LoopMeVPAIDErrorCodeMediaTimeOut = 402,
    LoopMeVPAIDErrorCodeMediaNotSupport = 403,
    LoopMeVPAIDErrorCodeMediaDisplay = 405,
    LoopMeVPAIDErrorCodeVerificationFail = 410,
    LoopMeVPAIDErrorCodeCompanionError = 600,
    LoopMeVPAIDErrorCodeUndefined = 900,
    LoopMeVPAIDErrorCodeVPAIDError = 901
};
