//
//  LoopMeAudioCheck.h
//  Tester
//
//  Created by Bohdan on 8/2/18.
//  Copyright © 2018 LoopMe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoopMeAudioCheck : NSObject

+ (instancetype)shared;

@property (nonatomic, strong) NSArray *currentOutputs;
@property (nonatomic, assign) BOOL isAudioPlaying;

@end
