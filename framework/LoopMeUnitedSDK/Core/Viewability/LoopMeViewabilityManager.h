//
//  LoopMeViewabilityManager.h
//  LoopMeSDK
//
//  Created by Bohdan on 1/10/18.
//  Copyright © 2018 loopmemedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoopMeViewabilityManager : NSObject

@property (nonatomic, assign, readonly) NSInteger visiblePersentage;

+ (instancetype)sharedInstance;

- (BOOL)isViewable:(UIView *)view;

@end
