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

NSInteger const kLoopMeVideoLoadTimeOutInterval = 60;
NSTimeInterval const kLoopMeVideoCacheExpiredTime = (-1*32*60*60);

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
@property (nonatomic, assign, getter=isDidLoadSent) BOOL didLoadSent;

- (NSString *)assetsDirectory;

@end

@implementation LoopMeVideoManager

#pragma mark - Life Cycle

- (void)dealloc {

}

- (instancetype)initWithVideoPath:(NSString *)videoPath delegate:(id<LoopMeVideoManagerDelegate>)delegate {
    self = [super init];
    if (self) {
        _videoPath = videoPath;
        _delegate = delegate;
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.timeoutIntervalForResource = kLoopMeVideoLoadTimeOutInterval;
        self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        [self clearOldCacheFiles];
    }
    return self;
}

#pragma mark - Private

- (NSString *)assetsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    return [documentsDirectory stringByAppendingPathComponent:@"lm_assets/"];
}

#pragma mark - Public

- (void)loadVideoWithURL:(NSURL *)URL {
    self.videoURL = URL;
    self.request = [NSMutableURLRequest requestWithURL:URL];
    self.dataTask = [self.session dataTaskWithRequest:self.request];
    [self.dataTask resume];
}

- (void)cancel {
    [self.dataTask cancel];
    self.dataTask = nil;
    [self.session invalidateAndCancel];
}

- (void)clearOldCacheFiles {
    NSFileManager *fm = [NSFileManager defaultManager];
    
    NSString *directoryPath = self.assetsDirectory;
    NSDirectoryEnumerator* enumerator = [fm enumeratorAtPath:directoryPath];
    
    NSString *file;
    while (file = [enumerator nextObject]) {

        NSDate *creationDate = [[fm attributesOfItemAtPath:[directoryPath stringByAppendingPathComponent:file] error:nil] fileCreationDate];
        NSDate *yesterDay = [[NSDate date] dateByAddingTimeInterval:kLoopMeVideoCacheExpiredTime];
        
        if ([creationDate compare:yesterDay] == NSOrderedAscending) {
            [fm removeItemAtPath:[directoryPath stringByAppendingPathComponent:file] error:nil];
        }
    }
}


- (void)cacheVideoData:(NSData *)data {
    NSString *directoryPath = self.assetsDirectory;
    
    [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath
                              withIntermediateDirectories:NO
                                               attributes:nil
                                                    error:nil];
    
    NSString *dataPath = [directoryPath stringByAppendingPathComponent:self.videoPath];
    NSURL *URL = [NSURL fileURLWithPath:dataPath];
    
    if([data writeToFile:dataPath atomically:NO]) {
        if (!self.isDidLoadSent) {
            [self.delegate videoManager:self didLoadVideo:URL];
            self.didLoadSent = YES;
        }
    } else {
        //CHECK ERROR
        [self.delegate videoManager:self didFailLoadWithError:[LoopMeVPAIDError errorForStatusCode:LoopMeVPAIDErrorCodeUndefined]];
    }
}

- (BOOL)hasCachedURL:(NSURL *)URL {
    if (!self.videoPath) {
        return NO;
    }
    
    NSString *videoPath = [[self assetsDirectory] stringByAppendingPathComponent:self.videoPath];
    return [[NSFileManager defaultManager] fileExistsAtPath:videoPath];
}

- (NSURL *)videoFileURL {
    NSString *dataPath = [[self assetsDirectory] stringByAppendingPathComponent:self.videoPath];
    NSURL *URL = [NSURL fileURLWithPath:dataPath];
    return URL;
}

- (void)failedInitPlayer:(NSURL *)URL {
    self.didLoadSent = NO;
    [self loadVideoWithURL:URL];
}

- (void)reconect {
    [self.request setValue:self.ETag forHTTPHeaderField:@"If-Range"];
    
    [self.request setValue:[NSString stringWithFormat:@"bytes=%lu-%lld", (unsigned long)self.videoData.length, self.contentLength] forHTTPHeaderField:@"Range"];
    self.dataTask = [self.session dataTaskWithRequest:self.request];
    [self.dataTask resume];
}

#pragma mark - NSURLConnectionDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    if ([response respondsToSelector:@selector(statusCode)]) {
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        if (statusCode == 200) {
            self.contentLength = [response expectedContentLength];
            self.ETag = [[(NSHTTPURLResponse *)response allHeaderFields] valueForKey:@"ETag"];
            self.videoData = [NSMutableData data];
            completionHandler(NSURLSessionResponseAllow);
            return;
        }
        if (statusCode != 206) {
            completionHandler(NSURLSessionResponseCancel);
            
            [LoopMeErrorEventSender sendError: LoopMeEventErrorTypeBadAsset
                                 errorMessage: [NSString stringWithFormat: @"response code %ld: %@", (long)statusCode, self.videoURL.absoluteString]
                                       appkey: self.delegate.appKey
                                         info: @[@"LoopMeVideoManager"]];
            //CHECK ERROR
            [self.delegate videoManager:self didFailLoadWithError:[LoopMeVPAIDError errorForStatusCode:LoopMeVPAIDErrorCodeTrafficking]];
        }
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
   didReceiveData:(NSData *)data {
    [self.videoData appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    if (error) {
        if (error.code == NSURLErrorNetworkConnectionLost) {
            [self reconect];
            return;
        } else {
            if (error.code == NSURLErrorTimedOut) {
                [LoopMeErrorEventSender sendError: LoopMeEventErrorTypeBadAsset
                                     errorMessage: [NSString stringWithFormat: @"Time out for: %@", self.videoURL.absoluteString]
                                           appkey: self.delegate.appKey
                                             info: @[@"LoopMeVideoManager"]];
                
                [self.delegate videoManager:self didFailLoadWithError:[LoopMeVPAIDError errorForStatusCode:LoopMeVPAIDErrorCodeMediaTimeOut]];
            } else if (error.code != NSURLErrorCancelled) {
                [LoopMeErrorEventSender sendError: LoopMeEventErrorTypeBadAsset
                                     errorMessage: [NSString stringWithFormat: @"Response code %ld: %@", (long)error.code, self.videoURL.absoluteString]
                                           appkey: self.delegate.appKey
                                             info: @[@"LoopMeVideoManager"]];
                
                [self.delegate videoManager:self didFailLoadWithError:[LoopMeVPAIDError errorForStatusCode:LoopMeVPAIDErrorCodeTrafficking]];
            }
        }
    } else {
        [self cacheVideoData:[NSData dataWithData:self.videoData]];
        self.videoData = nil;
        [self.dataTask cancel];
        self.dataTask = nil;
        [self.session invalidateAndCancel];
        self.session = nil;
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)redirectResponse
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest *))completionHandler {
    
    completionHandler(request);
}

@end
