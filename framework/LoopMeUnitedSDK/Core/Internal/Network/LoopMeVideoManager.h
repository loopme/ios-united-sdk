//
//  LoopMeVideoManager.h
//  LoopMeSDK
//
//  Created by Kogda Bogdan on 2/19/15.
//
//

#import <Foundation/Foundation.h>
@class LoopMeAdConfiguration;

@protocol LoopMeVideoManagerDelegate;

@interface LoopMeVideoManager : NSObject

@property (nonatomic, weak) id<LoopMeVideoManagerDelegate> delegate;

- (instancetype)initWithUniqueName:(NSString*)uniqueName delegate:(id<LoopMeVideoManagerDelegate>)delegate;
- (NSURL *)cacheVideoWith:(NSURL *)URL;
- (void)cancel;

@end

@protocol LoopMeVideoManagerDelegate

- (void)videoManager:(LoopMeVideoManager *)videoManager didLoadVideo:(NSURL *)videoURL;
- (void)videoManager:(LoopMeVideoManager *)videoManager didFailLoadWithError: (NSError *)error;
- (LoopMeAdConfiguration *)adConfigurationObject;

@end
