//
//  LoopMeVastLinks.m
//  LoopMeSDK
//
//  Copyright © 2016 LoopMe. All rights reserved.
//

#import "LoopMeVASTTrackingLinks.h"

@implementation LoopMeVASTTrackingLinks

- (void)dealloc {
    
}

- (instancetype)init {
    if (self = [super init]) {
        _errorLinkTemplates = [NSMutableSet new];
        _impressionLinks = [NSMutableSet new];
        _linearTrackingLinks = [[LoopMeVastLinearTrackingLinks alloc] init];
        _companionTrackingLinks = [[LoopMeVastCompanionAdsTrackingLinks alloc] init];
        _viewableImpression = [[LoopMeVASTViewableImpression alloc] init];
    }
    return self;
}

@end

@implementation LoopMeVastLinearTrackingLinks

- (void)dealloc {
    
}

- (instancetype)init {
    if (self = [super init]) {
        _start = [NSMutableSet new];
        _firstQuartile = [NSMutableSet new];
        _midpoint = [NSMutableSet new];
        _thirdQuartile = [NSMutableSet new];
        _complete = [NSMutableSet new];
        _closeLinear = [NSMutableSet new];
        _pause = [NSMutableSet new];
        _resume = [NSMutableSet new];
        _expand = [NSMutableSet new];
        _collapse = [NSMutableSet new];
        _skip = [NSMutableSet new];
        _mute = [NSMutableSet new];
        _unmute = [NSMutableSet new];
        _progress = [NSMutableSet new];
        _expand = [NSMutableSet new];
        _collapse = [NSMutableSet new];
        _creativeView = [NSMutableSet new];
        _clickTracking = [NSMutableSet new];
    }
    return self;
}

-(void)add:(LoopMeVastLinearTrackingLinks *)links {
    [self.creativeView addObjectsFromArray:[links.creativeView allObjects]];
    [self.clickTracking addObjectsFromArray:[links.clickTracking allObjects]];
    [self.start addObjectsFromArray:[links.start allObjects]];
    [self.firstQuartile addObjectsFromArray:[links.firstQuartile allObjects]];
    [self.midpoint addObjectsFromArray:[links.midpoint allObjects]];
    [self.thirdQuartile addObjectsFromArray:[links.thirdQuartile allObjects]];
    [self.complete addObjectsFromArray:[links.complete allObjects]];
    [self.closeLinear addObjectsFromArray:[links.closeLinear allObjects]];
    [self.pause addObjectsFromArray:[links.pause allObjects]];
    [self.resume addObjectsFromArray:[links.resume allObjects]];
    [self.expand addObjectsFromArray:[links.expand allObjects]];
    [self.collapse addObjectsFromArray:[links.collapse allObjects]];
    [self.skip addObjectsFromArray:[links.skip allObjects]];
    [self.mute addObjectsFromArray:[links.mute allObjects]];
    [self.unmute addObjectsFromArray:[links.unmute allObjects]];
    [self.progress addObjectsFromArray:[links.progress allObjects]];
}

@end

@implementation LoopMeVastCompanionAdsTrackingLinks

- (void)dealloc {
    
}

- (instancetype)init {
    if (self = [super init]) {
        _creativeView = [NSMutableSet new];
        _clickTracking = [NSMutableSet new];
    }
    return self;
}

- (void)add:(LoopMeVastCompanionAdsTrackingLinks *)links {
    [self.creativeView addObjectsFromArray:[links.creativeView allObjects]];
    [self.clickTracking addObjectsFromArray:[links.clickTracking allObjects]];
}

@end

@implementation LoopMeVASTViewableImpression

- (instancetype)init {
    if (self = [super init]) {
        _viewable = [NSMutableSet new];
        _notViewable = [NSMutableSet new];
        _viewUndetermined = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)add:(LoopMeVASTViewableImpression *)links {
    [self.viewable addObjectsFromArray:[links.viewable allObjects]];
    [self.notViewable addObjectsFromArray:[links.notViewable allObjects]];
    [self.viewUndetermined addObjectsFromArray:[links.viewUndetermined allObjects]];
}

@end
