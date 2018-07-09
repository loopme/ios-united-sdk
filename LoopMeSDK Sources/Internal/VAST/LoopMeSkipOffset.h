//
//  LoopMeSkipOffset.h
//  LoopMeSDK
//
//  Created by Bohdan on 11/24/16.
//  Copyright © 2016 LoopMe. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, LoopMeSkipOffsetType) {
    LoopMeSkipOffsetTypeSec,
    LoopMeSkipOffsetTypePercentage
};

typedef struct {
    LoopMeSkipOffsetType type;
    NSUInteger value;
} LoopMeSkipOffset;

extern const LoopMeSkipOffset kLoopMeSkipOffsetZero;
