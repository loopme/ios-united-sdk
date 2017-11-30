//
//  LoopMeORTBTools.h
//  Tester
//
//  Created by Bohdan on 4/5/17.
//  Copyright © 2017 LoopMe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoopMeORTBTools : NSObject

+ (NSData *)makeRequestBodyWithAppKey:(NSString *)appKey targeting:(LoopMeTargeting *)targeting
                      integrationType:(NSString *)integrationType adSpotSize:(CGSize)size;

@end
