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
    if (imageURL) {
        [self.downloadQueue addOperationWithBlock:^{
            NSError *error = nil;
            if ([[LoopMeDiscURLCache sharedDiscCache] cachedDataExistsForKey:imageURL.absoluteString]) {
                NSData *cachedImageData = [[LoopMeDiscURLCache sharedDiscCache] retrieveDataForKey:imageURL.absoluteString];
                UIImage *image = [UIImage imageWithData:cachedImageData];
                if (image) {
                    // By default, the image data isn't decompressed until set on a UIImageView, on the main thread. This
                    // can result in poor scrolling performance. To fix this, we force decompression in the background before
                    // assignment to a UIImageView.
                    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
                    [image drawAtPoint:CGPointZero];
                    UIGraphicsEndImageContext();
                    self.downloadedImage = image;
                } else {
                    error = [LoopMeVPAIDError errorForStatusCode:LoopMeVPAIDErrorCodeCompanionError];
                }
            } else {
                NSURLResponse *response = nil;
                NSData *imageData = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:imageURL] returningResponse:&response error:&error];
                BOOL validImage = imageData != nil;
                if (validImage) {
                    self.downloadedImage = [UIImage imageWithData:imageData];
                    if (self.downloadedImage) {
                        [[LoopMeDiscURLCache sharedDiscCache] storeData:imageData forKey:imageURL.absoluteString];
                    } else {
                        LoopMeLogDebug(@"Error: invalid image data.");
                        if (!error) {
                            error = [LoopMeVPAIDError errorForStatusCode:LoopMeVPAIDErrorCodeCompanionError];
                        }
                    }
                }
            }
            self.error = error;
        }];
    }
    
    
    [self.downloadQueue addOperationWithBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.delegate imageDownloader:self didLoadImage:self.downloadedImage withError:self.error];
        }];
    }];
}

@end
