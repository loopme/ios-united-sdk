//
//  LoopMeVASTProgressEvent.m
//  LoopMeSDK
//
//  Copyright © 2016 LoopMe. All rights reserved.
//

#import "LoopMeVASTProgressEvent.h"
#import "LoopMeVPAIDConverter.h"

@implementation LoopMeVASTProgressEvent

- (instancetype)initWithOffset:(NSString *)offset link:(NSString *)link {
    if (self = [super init]) {
        _offset = [LoopMeVPAIDConverter timeFromString:offset];
        _link = link;
    }
    
    return self;
}

+ (instancetype)eventWithOffset:(NSString *)offset link:(NSString *)link {
    return [[LoopMeVASTProgressEvent alloc] initWithOffset:offset link:link];
}

@end
