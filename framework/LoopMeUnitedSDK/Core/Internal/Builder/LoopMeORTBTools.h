//
//  LoopMeORTBTools.h
//  LoopMeSDK
//
//  Created by Bohdan on 4/5/17.
//  Copyright © 2017 LoopMe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoopMeORTBTools : NSObject

@property (nonatomic, strong) NSString * _Nonnull appKey;
@property (nonatomic, weak) LoopMeTargeting * _Nullable targeting;
@property (nonatomic, strong) NSString * _Nonnull integrationType;
@property (nonatomic, assign) CGSize size;

@property (nonatomic, assign) BOOL video;
@property (nonatomic, assign) BOOL banner;

- (instancetype _Nullable)initWithAppKey: (NSString * _Nonnull)appKey
                               targeting: (LoopMeTargeting * _Nullable)targeting
                              adSpotSize: (CGSize)size
                         integrationType: (NSString * _Nonnull)integrationType
                              isRewarded: (BOOL)isRewarded;
- (NSData * _Nonnull )makeRequestBody;

@end
