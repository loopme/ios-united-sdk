//
//  LoopMeVASTImageDownloader.m
//  LoopMeSDK
//
//  Copyright © 2016 LoopMe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoopMeVASTImageDownloader.h"
#import "LoopMeDiscURLCache.h"
#import "LoopMeLogging.h"
#import "LoopMeVPAIDError.h"

@interface LoopMeVASTImageDownloader ()

@property (nonatomic, strong) NSOperationQueue *downloadQueue;
@property (nonatomic, strong) UIImage *downloadedImage;
@property (nonatomic, strong) NSError *error;

@end

@implementation LoopMeVASTImageDownloader

- (void)dealloc {
    
}

- (instancetype)initWithDelegate:(id<LoopMeVASTImageDownloaderDelegate>)delegate {
    self = [super init];
    if (self) {
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.maxConcurrentOperationCount = 1;
        _delegate = delegate;
    }
    return self;
}

- (void)loadImageWithURL:(NSURL *)imageURL {
    if (!imageURL) {
        NSError *error = [LoopMeVPAIDError errorForStatusCode:LoopMeVPAIDErrorCodeCompanionError];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate imageDownloader:self didLoadImage:nil withError:error];
        });
        return;
    }
    
    [self.downloadQueue addOperationWithBlock:^{
        __block NSError *localError = nil;
        __block UIImage *image = nil;
        
        if ([[LoopMeDiscURLCache sharedDiscCache] cachedDataExistsForKey:imageURL.absoluteString]) {
            NSData *cachedImageData = [[LoopMeDiscURLCache sharedDiscCache] retrieveDataForKey:imageURL.absoluteString];
            image = [UIImage imageWithData:cachedImageData];
            if (image) {
                // By default, the image data isn't decompressed until set on a UIImageView, on the main thread. This
                // can result in poor scrolling performance. To fix this, we force decompression in the background before
                // assignment to a UIImageView.
                UIGraphicsBeginImageContext(CGSizeMake(1, 1));
                [image drawAtPoint:CGPointZero];
                UIGraphicsEndImageContext();
            } else {
                localError = [LoopMeVPAIDError errorForStatusCode:LoopMeVPAIDErrorCodeCompanionError];
            }
        } else {
            NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
            
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            
            NSURLSessionDataTask *task = [session dataTaskWithURL:imageURL completionHandler:^(NSData *data, NSURLResponse *response, NSError *taskError) {
                if (taskError) {
                    LoopMeLogDebug(@"Error downloading image: %@", taskError);
                    localError = taskError;
                } else if (data) {
                    UIImage *downloadedImage = [UIImage imageWithData:data];
                    if (downloadedImage) {
                        [[LoopMeDiscURLCache sharedDiscCache] storeData:data forKey:imageURL.absoluteString];
                        image = downloadedImage;
                        // Pre-decompress image
                        UIGraphicsBeginImageContext(CGSizeMake(1, 1));
                        [downloadedImage drawAtPoint:CGPointZero];
                        UIGraphicsEndImageContext();
                    } else {
                        LoopMeLogDebug(@"Error: invalid image data.");
                        localError = [LoopMeVPAIDError errorForStatusCode:LoopMeVPAIDErrorCodeCompanionError];
                    }
                }
                dispatch_semaphore_signal(semaphore);
            }];
            [task resume];
            
            // Wait for the download to complete
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
        
        self.downloadedImage = image;
        self.error = localError;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.delegate imageDownloader:self didLoadImage:self.downloadedImage withError:self.error];
        }];
    }];
}

@end
