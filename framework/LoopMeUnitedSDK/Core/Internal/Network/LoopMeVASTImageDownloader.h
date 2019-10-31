//
//  LoopMeVASTImageDownloader.h
//  LoopMeSDK
//
//  Copyright © 2016 LoopMe. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LoopMeVASTImageDownloaderDelegate;
@interface LoopMeVASTImageDownloader : NSObject

@property (nonatomic, weak) id<LoopMeVASTImageDownloaderDelegate> delegate;

- (instancetype)initWithDelegate:(id<LoopMeVASTImageDownloaderDelegate>) delegate;
- (void)loadImageWithURL:(NSURL *)imageURL;

@end

@protocol LoopMeVASTImageDownloaderDelegate <NSObject>

- (void)imageDownloader:(LoopMeVASTImageDownloader *)downloader didLoadImage:(UIImage *)image withError:(NSError *)error;

@end
