//
//  LoopMeVPAIDError.m
//  LoopMeSDK
//
//  Copyright (c) 2016 LoopMe. All rights reserved.
//

#import "LoopMeVPAIDError.h"

@implementation LoopMeVPAIDError

+ (NSError *)errorForStatusCode:(NSInteger)statusCode {
    NSString *errorMessage;
    switch (statusCode) {
        case LoopMeVPAIDErrorCodeXMLParsingFailed:
            errorMessage = @"XML parsing error.";
            break;
        case LoopMeVPAIDErrorCodeTrafficking:
            errorMessage = @"Video player received an Ad type that it was not expecting and/or cannot display.";
            break;
        case LoopMeVPAIDErrorCodeWrapperTimeOut:
            errorMessage = @"AD TAG URI was either unavailable or reached a timeout.";
            break;
        case LoopMeVPAIDErrorCodeWrapperLimit:
            errorMessage = @"Too many Wrapper responses have been received with no InLine response.";
            break;
        case LoopMeVPAIDErrorCodeWrapperNoVAST:
            errorMessage = @"No VAST response after one or more Wrappers.";
            break;
        case LoopMeVPAIDErrorCodeMediaTimeOut:
            errorMessage = @"Timeout of MediaFile URI.";
            break;
        case LoopMeVPAIDErrorCodeMediaNotFound:
            errorMessage = @"File not found. Unable to find Linear/MediaFile from URI.";
            break;
        case LoopMeVPAIDErrorCodeMediaNotSupport:
            errorMessage = @"Couldn’t find MediaFile that is supported by this video player.";
            break;
        case LoopMeVPAIDErrorCodeMediaDisplay:
            errorMessage = @"Problem displaying MediaFile.";
            break;
        case LoopMeVPAIDErrorCodeCompanionError:
            errorMessage = @"General CompanionAds error.";
            break;
        case LoopMeVPAIDErrorCodeVPAIDError:
            errorMessage = @"General VPAID error";
            break;
        default:
            statusCode = 900;
            errorMessage = @"Undefined error";
            break;
    }
    
    NSDictionary *errorInfo = @{NSLocalizedDescriptionKey:errorMessage};
    return [NSError errorWithDomain:kLoopMeErrorDomain code:statusCode userInfo:errorInfo];
}

@end
