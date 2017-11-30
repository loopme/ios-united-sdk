//
//  LoopMeVideoManager.h
//  LoopMeSDK
//
//  Created by Kogda Bogdan on 2/19/15.
//
//

#import <Foundation/Foundation.h>

@protocol LoopMeVideoManagerDelegate;

@interface LoopMeVideoManager : NSObject

@property (nonatomic, weak) id<LoopMeVideoManagerDelegate> delegate;

- (instancetype)initWithVideoPath:(NSString *)videoPath delegate:(id<LoopMeVideoManagerDelegate>)delegate;
- (void)loadVideoWithURL:(NSURL *)URL;
- (void)cacheVideoData:(NSData *)data;
- (BOOL)hasCachedURL:(NSURL *)URL;
- (NSURL *)videoFileURL;
- (void)cancel;
- (void)failedInitPlayer: (NSURL *)url;

@end

@protocol LoopMeVideoManagerDelegate

- (void)videoManager:(LoopMeVideoManager *)videoManager didLoadVideo:(NSURL *)videoURL;
- (void)videoManager:(LoopMeVideoManager *)videoManager didFailLoadWithError:(NSError *)error;
- (NSString *)appKey;

@end
