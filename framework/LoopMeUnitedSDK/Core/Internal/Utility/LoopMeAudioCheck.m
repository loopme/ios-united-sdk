//
//  LoopMeAudioCheck.m
//  Tester
//
//  Created by Bohdan on 8/2/18.
//  Copyright © 2018 LoopMe. All rights reserved.
//

#import "LoopMeAudioCheck.h"
#import <AVFoundation/AVFoundation.h>

@implementation LoopMeAudioCheck

+ (instancetype)shared {
    static LoopMeAudioCheck *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LoopMeAudioCheck alloc] init];
    });
    
    return instance;
}

- (NSArray *)currentOutputs {    
    NSMutableArray *outputs = [NSMutableArray new];
    AVAudioSessionRouteDescription *currentRoute = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription *description in currentRoute.outputs) {
        [outputs addObject:[description.portType lowercaseString]];
    }
    return outputs;
}

- (BOOL)isAudioPlaying {
    return [[AVAudioSession sharedInstance] isOtherAudioPlaying];
}

@end
