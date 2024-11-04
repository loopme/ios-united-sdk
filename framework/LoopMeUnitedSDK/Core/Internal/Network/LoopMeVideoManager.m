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
NSTimeInterval const kLoopMeVideoCacheExpiredTime = 32 * 60 * 60;
static NSTimeInterval const kLoopMeVideoCacheDelay = 5.0;

@interface LoopMeVideoManager () <NSURLSessionDownloadDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSString *assetsDirectory;
@property (nonatomic, strong) NSLock *lock;
@property (nonatomic, strong) NSTimer *cacheTimer;
@property (nonatomic, strong) NSMutableDictionary<NSURL *, NSURLSessionDownloadTask *> *downloadTasks;

@end

@implementation LoopMeVideoManager

#pragma mark - Singleton



- (instancetype)initWithDelegate:(id<LoopMeVideoManagerDelegate>)delegate {
    self = [super init];
    if (self) {
        _lock = [[NSLock alloc] init];
        _downloadTasks = [NSMutableDictionary dictionary];
        [self setDelegate:delegate];
        NSString *domainDir = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        _assetsDirectory = [domainDir stringByAppendingPathComponent:@"lm_assets/"];

        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.timeoutIntervalForResource = kLoopMeVideoLoadTimeOutInterval;
        self.session = [NSURLSession sessionWithConfiguration:configuration
                                                     delegate:self
                                                delegateQueue:nil];
        [self clearCacheFilesOlderThan:kLoopMeVideoCacheExpiredTime];
    }
    return self;
}

#pragma mark - Public Methods

- (void)setDelegate:(id<LoopMeVideoManagerDelegate>)delegate {
    [self.lock lock];
    _delegate = delegate;
    [self.lock unlock];
}

- (NSURL *)cacheVideoWith:(NSURL *)URL {
    [self.lock lock];
    NSString *localPath = [self localPathForURL:URL];

    if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
        [self.lock unlock];
        return [NSURL fileURLWithPath:localPath];
    }

    [self startCachingURL:URL];
    [self.lock unlock];
    return URL;
}

- (void)cancel {
    [self.lock lock];
    for (NSURLSessionDownloadTask *downloadTask in self.downloadTasks.allValues) {
        [downloadTask cancel];
    }
    [self.downloadTasks removeAllObjects];
    [self.lock unlock];
}

#pragma mark - Private Methods

- (void)startCachingURL:(NSURL *)URL {
    [self.lock lock];

    if (!self.session) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.timeoutIntervalForResource = kLoopMeVideoLoadTimeOutInterval;
        self.session = [NSURLSession sessionWithConfiguration:configuration
                                                     delegate:self
                                                delegateQueue:nil];
    }
    if (self.downloadTasks[URL]) {
          return;
      }

    NSURLSessionDownloadTask *downloadTask = [self.session downloadTaskWithURL:URL];
    self.downloadTasks[URL] = downloadTask;
    [downloadTask resume];
    self.cacheTimer = nil;

    [self.lock unlock];
}

- (NSString *)localPathForURL:(NSURL *)URL {
    NSString *fileName = [NSString stringWithFormat:@"%@.mp4", [URL.absoluteString lm_MD5]];
    return [self.assetsDirectory stringByAppendingPathComponent:fileName];
}

- (void)clearCacheFilesOlderThan:(NSTimeInterval)cacheLifetime {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:self.assetsDirectory]) {
        return;
    }

    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtPath:self.assetsDirectory];
    NSString *file;
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-cacheLifetime];

    while ((file = [enumerator nextObject])) {
        NSString *filePath = [self.assetsDirectory stringByAppendingPathComponent:file];
        NSError *attributesError = nil;
        NSDictionary *attributes = [fileManager attributesOfItemAtPath:filePath error:&attributesError];

        if (attributesError) {
            continue;
        }

        NSDate *creationDate = attributes[NSFileCreationDate];
        if ([creationDate compare:expirationDate] == NSOrderedAscending) {
            NSError *removeError = nil;
            if (![fileManager removeItemAtPath:filePath error:&removeError]) {
            }
        }
    }
}

#pragma mark - NSURLSessionDownloadDelegate

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    NSURL *originalURL = downloadTask.originalRequest.URL;
    NSString *localPath = [self localPathForURL:originalURL];
    NSError *error = nil;

    // Ensure directory exists
    [[NSFileManager defaultManager] createDirectoryAtPath:self.assetsDirectory
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    if (error) {
        return;
    }

    [[NSFileManager defaultManager] moveItemAtURL:location
                                            toURL:[NSURL fileURLWithPath:localPath]
                                            error:&error];
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate videoManager:self didFailLoadWithError:error];
        });
    }

    [self.lock lock];
    [self.downloadTasks removeObjectForKey:originalURL];
    [self.lock unlock];
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    NSURL *originalURL = task.originalRequest.URL;

    if (error) {
        [self.lock lock];
        [self.downloadTasks removeObjectForKey:originalURL];
        [self.lock unlock];

        // Notify delegate on main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableDictionary *infoDictionary = [[self.delegate adConfigurationObject] toDictionary].mutableCopy;
            infoDictionary[kErrorInfoClass] = @"LoopMeVideoManager";
            infoDictionary[kErrorInfoUrl] = originalURL.absoluteString;

            [LoopMeErrorEventSender sendError:LoopMeEventErrorTypeBadAsset
                                 errorMessage:error.localizedDescription
                                         info:infoDictionary];

                [self.delegate videoManager:self didFailLoadWithError:error];
        });
    }
}

@end
