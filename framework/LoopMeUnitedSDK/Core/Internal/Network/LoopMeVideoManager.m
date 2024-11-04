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

@property (nonatomic, strong) NSString *uniqueName;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSString *assetsDirectory;
@property (nonatomic, strong) NSTimer *cacheTimer;
@property (nonatomic, strong) NSMutableDictionary<NSURL *, NSURLSessionDownloadTask *> *downloadTasks;

@end

@implementation LoopMeVideoManager

#pragma mark - Singleton

- (instancetype)initWithUniqueName:(NSString*)uniqueName delegate:(id<LoopMeVideoManagerDelegate>)delegate {
    self = [super init];
    if (self) {
        _downloadTasks = [NSMutableDictionary dictionary];
        _delegate = delegate;
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
    _delegate = delegate;
}

- (NSURL *)cacheVideoWith:(NSURL *)URL {
    NSString *localPath = [self localPathForURL:URL];

    if ([[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
        return [NSURL fileURLWithPath:localPath];
    }

    [self startCachingURL:URL];
    return URL;
}

- (void)cancel {
    for (NSURLSessionDownloadTask *downloadTask in self.downloadTasks.allValues) {
        [downloadTask cancel];
    }
    [self.downloadTasks removeAllObjects];
}

#pragma mark - Private Methods

- (void)startCachingURL:(NSURL *)URL {
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
}

- (NSString *)localPathForURL:(NSURL *)URL {
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.mp4", _uniqueName, [URL.absoluteString lm_MD5]];
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
    NSURL *localURL = [NSURL fileURLWithPath:localPath];
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

    [self.downloadTasks removeObjectForKey:originalURL];
    
    [self.delegate videoManager:self didLoadVideo:localURL];

}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    NSURL *originalURL = task.originalRequest.URL;

    if (error) {
        [self.downloadTasks removeObjectForKey:originalURL];

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
