//
//  AnalyticsProvider.h
//
//  Created by Bohdan on 2/29/16.
//  Copyright © 2016 LoopMe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoopMeAnalyticsProvider : NSObject

@property (nonatomic, strong) NSString *analyticURLString;

+ (instancetype)sharedInstance;

@end
