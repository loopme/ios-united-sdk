//
//  LoopMeError.m
//  LoopMeSDK
//
//  Created by Kogda Bogdan on 2/18/15.
//
//

#import "LoopMeError.h"
#import "LoopMeDefinitions.h"

@implementation LoopMeError

+ (NSError *)errorForStatusCode:(NSInteger)statusCode {
    NSString *errorMessage;
    // Server returns 404 status code for incorrect appKey
    if (statusCode == 404) {
        errorMessage = @"Missing or invalid appkey";
    } else if (statusCode == 204) {
        errorMessage = @"No ads found";
    } else if (statusCode == LoopMeErrorCodeHTMLRequestTimeOut){
        errorMessage = @"Ad processing timed out";
    } else if (statusCode == LoopMeErrorCodeSpecificHost) {
        errorMessage = @"Failed to process ad";
    } else if (statusCode == LoopMeErrorCodeIncorrectFormat) {
        errorMessage = @"Could not process ad: wrong format";
    } else if (statusCode == LoopMeErrorCodeURLResolve) {
        errorMessage = @"Failed to resolve URL";
    } else if (statusCode == LoopMeErrorCodeWrirtingToDisk) {
        errorMessage = @"Error writing to disk";
    } else if (statusCode == LoopMeErrorCodeCanNotLoadVideo){
        errorMessage = @"Can not load video without Wi-Fi connection";
    } else if (statusCode == LoopMeErrorCodeVideoDownloadTimeout) {
        errorMessage = @"Video download timeout";
    } else if (statusCode == LoopMeErrorCodeNoResourceBundle) {
        errorMessage = @"mraid.js does not exist in the project";
    } else if (statusCode == LoopMeErrorCodeIncorrectResponse) {
        errorMessage = @"Incorrect response";
    } else if (statusCode == LoopMeErrorCodeInvalidRequest) {
        errorMessage = @"Container size is not valid for chosen ad type";
    } else {
        errorMessage = [NSString stringWithFormat:@"API returned status code %ld.", (long)statusCode];
    }
    NSDictionary *errorInfo = @{NSLocalizedDescriptionKey:errorMessage};
    return [NSError errorWithDomain:kLoopMeErrorDomain code:statusCode userInfo:errorInfo];
}

@end
