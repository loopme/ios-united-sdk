//
//  LoopMeAdType.h
//  LoopMeSDK
//
//  Created by Bohdan on 3/21/18.
//  Copyright © 2018 LoopMe. All rights reserved.
//
#import <Foundation/Foundation.h>
#ifndef LoopMeAdType_h
#define LoopMeAdType_h

typedef NS_ENUM(NSUInteger, LoopMeAdType) {
    LoopMeAdTypeVideo = 1 << 0,
    LoopMeAdTypeHTML  = 1 << 1,
    LoopMeAdTypeAll   = ((1 << 1) + LoopMeAdTypeVideo)
};

#endif /* LoopMeAdType_h */
