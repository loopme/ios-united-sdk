//
//  LoopMeVideoManager.m
//  LoopMeSDK
//
//  Copyright (c) 2016 LoopMe. All rights reserved.
//

#import <stdlib.h>
#import "LoopMeVideoManager.h"
#import "LoopMeVPAIDError.h"
#import "LoopMeErrorEventSender.h"
#import <LoopMeUnitedSDK/LoopMeUnitedSDK-Swift.h>
#import "LoopMeDefinitions.h"
#import "NSString+Encryption.h"

NSInteger const kLoopMeVideoLoadTimeOutInterval = 60;
NSTimeInterval const kLoopMeVideoCacheExpiredTime = (-1 * 32 * 60 * 60);

@interface LoopMeVideoManager ()
<
    NSURLSessionTaskDelegate,
    NSURLSessionDataDelegate
>

@property (nonatomic, strong) id ETag;
@property (nonatomic, strong) NSMutableURLRequest *request;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSMutableData *videoData;

@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) NSString *videoPath;
@property (nonatomic, assign) long long contentLength;

@property (nonatomic, strong) NSString *assetsDirectory;

@end

@implementation LoopMeVideoManager

#pragma mark - Life Cycle

- (void)dealloc { }

- (void)clearCacheFilesOlderThan: (NSTimeInterval)cacheLifetime {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![[NSFileManager defaultManager] fileExistsAtPath: self.assetsDirectory]) {
        return;
    }
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath: self.assetsDirectory];
    NSString *file;
    NSDate *expirationDate = [[NSDate date] dateByAddingTimeInterval: -cacheLifetime];
    while (file = [enumerator nextObject]) {
        NSString *filePath = [self.assetsDirectory stringByAppendingPathComponent: file];
        NSError *attributesError = nil;
        NSDate *creationDate = [[fileManager attributesOfItemAtPath: filePath error: &attributesError] fileCreationDate];
        if (attributesError) {
            NSLog(@"Failed to get attributes for file: %@, error: %@", file, attributesError);
            continue;
        }
        if ([creationDate compare: expirationDate] == NSOrderedDescending) {
            NSError *removeError = nil;
            if (![fileManager removeItemAtPath: filePath error: &removeError]) {
                NSLog(@"Failed to remove file: %@, error: %@", file, removeError);
            }
        }
    }
}

- (instancetype)initWithVideo: (NSURL *)URL delegate: (id<LoopMeVideoManagerDelegate>)delegate {
    self = [super init];
    if (self) {
        _videoURL = URL;
        _videoPath = [NSString stringWithFormat: @"%@.mp4", [URL.absoluteString lm_MD5]];
        _delegate = delegate;
        NSString *domainDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
        _assetsDirectory = [domainDir stringByAppendingPathComponent: @"lm_assets/"];
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.timeoutIntervalForResource = kLoopMeVideoLoadTimeOutInterval;
        self.session = [NSURLSession sessionWithConfiguration: configuration
                                                     delegate: self
                                                delegateQueue: nil];
        [self clearCacheFilesOlderThan: kLoopMeVideoCacheExpiredTime];
    }
    return self;
}

#pragma mark - Public

// TODO: Singleton + synchronization to not load the same video at short period of time
- (NSURL *)cacheVideoWith: (NSURL *)URL {
    self.videoURL = URL;
    self.videoPath = [NSString stringWithFormat: @"%@.mp4", [URL.absoluteString lm_MD5]];
    NSString *localPath = [self.assetsDirectory stringByAppendingPathComponent: self.videoPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath: localPath]) {
        return [NSURL fileURLWithPath: localPath];
    }
    self.request = [NSMutableURLRequest requestWithURL: URL];
    self.dataTask = [self.session dataTaskWithRequest: self.request];
    [self.dataTask resume];
    return URL;
}

- (void)cancel {
    [self.dataTask cancel];
    self.dataTask = nil;
    [self.session invalidateAndCancel];
}

#pragma mark - NSURLConnectionDelegate

- (void)URLSession: (NSURLSession *)session
          dataTask: (NSURLSessionDataTask *)dataTask
didReceiveResponse: (NSURLResponse *)response
 completionHandler: (void (^)(NSURLSessionResponseDisposition))completionHandler {
    if (![response respondsToSelector: @selector(statusCode)]) {
        return;
    }
    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
    if (statusCode == 206) {
        return;
    }
    if (statusCode == 200) {
        self.contentLength = [response expectedContentLength];
        self.ETag = [[(NSHTTPURLResponse *)response allHeaderFields] valueForKey: @"ETag"];
        self.videoData = [NSMutableData data];
        completionHandler(NSURLSessionResponseAllow);
        return;
    }
    completionHandler(NSURLSessionResponseCancel);
    NSMutableDictionary *infoDictionary = [self.delegate.adConfigurationObject toDictionary];
    infoDictionary[kErrorInfoClass] = @"LoopMeVideoManager";
    infoDictionary[kErrorInfoUrl] = self.videoURL.absoluteString;
    [LoopMeErrorEventSender sendError: LoopMeEventErrorTypeBadAsset
                         errorMessage: [NSString stringWithFormat: @"Response code: %ld", (long)statusCode]
                                 info: infoDictionary];
    [self.delegate videoManager: self
           didFailLoadWithError: [LoopMeVPAIDError errorForStatusCode: LoopMeVPAIDErrorCodeTrafficking]];
}

- (void)URLSession: (NSURLSession *)session
          dataTask: (NSURLSessionDataTask *)dataTask
    didReceiveData: (NSData *)data {
    [self.videoData appendData: data];
}

- (void)reconect {
    [self.request setValue: self.ETag forHTTPHeaderField: @"If-Range"];
    [self.request setValue: [NSString stringWithFormat: @"bytes=%lu-%lld", (unsigned long)self.videoData.length, self.contentLength]
        forHTTPHeaderField: @"Range"];
    self.dataTask = [self.session dataTaskWithRequest: self.request];
    [self.dataTask resume];
}

- (void)cacheVideoData: (NSData *)data {
    [[NSFileManager defaultManager] createDirectoryAtPath: self.assetsDirectory
                              withIntermediateDirectories: NO
                                               attributes: nil
                                                    error: nil];
    NSString *localPath = [self.assetsDirectory stringByAppendingPathComponent: self.videoPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath: localPath]) {
        NSLog(@"Already cached");
        return;
    }
    if (![data writeToFile: localPath atomically: NO]) {
        [self.delegate videoManager: self
               didFailLoadWithError: [LoopMeVPAIDError errorForStatusCode: LoopMeVPAIDErrorCodeUndefined]];
        return;
    }
}

- (void)URLSession: (NSURLSession *)session
              task: (NSURLSessionTask *)task
didCompleteWithError: (NSError *)error {
    if (!error) {
        [self cacheVideoData: [NSData dataWithData: self.videoData]];
        self.videoData = nil;
        [self.dataTask cancel];
        self.dataTask = nil;
        [self.session invalidateAndCancel];
        self.session = nil;
        return;
    }
    NSMutableDictionary *infoDictionary = [self.delegate.adConfigurationObject toDictionary];
    infoDictionary[kErrorInfoClass] = @"LoopMeVideoManager";
    infoDictionary[kErrorInfoUrl] = self.videoURL.absoluteString;
    if (error.code == NSURLErrorNetworkConnectionLost) {
        [self reconect];
        return;
    }
    if (error.code == NSURLErrorTimedOut) {
        [LoopMeErrorEventSender sendError: LoopMeEventErrorTypeBadAsset
                             errorMessage: [NSString stringWithFormat: @"Time out for"]
                                     info: infoDictionary];
        [self.delegate videoManager: self
               didFailLoadWithError: [LoopMeVPAIDError errorForStatusCode: LoopMeVPAIDErrorCodeMediaTimeOut]];
        return;
    }
    if (error.code != NSURLErrorCancelled) {
        [LoopMeErrorEventSender sendError: LoopMeEventErrorTypeBadAsset
                             errorMessage: [NSString stringWithFormat: @"Response code %ld:", (long)error.code]
                                     info: infoDictionary];
        [self.delegate videoManager: self
               didFailLoadWithError: [LoopMeVPAIDError errorForStatusCode: LoopMeVPAIDErrorCodeTrafficking]];
    }
}

- (void)URLSession: (NSURLSession *)session
              task: (NSURLSessionTask *)task
willPerformHTTPRedirection: (NSHTTPURLResponse *)redirectResponse
        newRequest: (NSURLRequest *)request
 completionHandler: (void (^)(NSURLRequest *))completionHandler {
    completionHandler(request);
}

@end
