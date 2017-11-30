//
//  LoopMeVASTProgressEvent.h
//  LoopMe
//
//  Copyright © 2016 LoopMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

@interface LoopMeVASTProgressEvent : NSObject

+ (instancetype)eventWithOffset:(NSString *)offset link:(NSString *)link;
- (instancetype)initWithOffset:(NSString *)offset link:(NSString *)link;
@property (nonatomic) CMTime offset;
@property (nonatomic) NSString *link;

@end
