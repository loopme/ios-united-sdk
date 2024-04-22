//
//  LoopMeGDPRAPIService.h
//  LoopMeSDK
//
//  Created by Bohdan on 4/27/18.
//  Copyright © 2018 LoopMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoopMeGDPRTools.h"

@interface LoopMeGDPRAPIService : NSObject

+ (NSDictionary *)apiResponse:(NSString *)deviceID ignoreCache:(BOOL)ignoreCache;

@end
