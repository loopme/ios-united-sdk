//
//  LoopMeVastXMLParser.h
//  LoopMeSDK
//
//  Copyright © 2016 LoopMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import "LoopMeVASTTrackingLinks.h"
#import "LoopMeVASTAssetLinks.h"
#import "LoopMeSkipOffset.h"

@interface LoopMeVASTXMLParser : NSObject

@property (nonatomic, readonly, getter = isWrapper) BOOL wrapper;

- (instancetype)initXMLWithData:(NSData *)data error:(NSError **)error;

- (void)initializeVastTrackingLinks:(LoopMeVASTTrackingLinks *)vastLinks;
- (void)initializeVastAssetLinks:(LoopMeVASTAssetLinks *)vastLinks error:(NSError **)error;
- (void)initializeAdVerifications:(LoopMeVASTTrackingLinks *)trackingLinks;

- (NSString *)vastFileContent;
- (NSString *)adTagURL:(NSError **)error;
- (NSString *)videoClickThrough;
- (NSString *)companionClickThrough;
- (LoopMeSkipOffset)skipOffset;
- (CMTime)duration;
- (NSString *)adID;

@end
