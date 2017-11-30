//
//  LoopMeVastEventSender.m
//  NewTestApp
//
//  Created by Bohdan on 6/15/16.
//  Copyright © 2016 LoopMe. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "LoopMeVASTEventTracker.h"
#import "LoopMeVASTProgressEvent.h"
#import "LoopMeVASTTrackingLinks.h"
#import "LoopMeVPAIDError.h"

@interface LoopMeVASTEventTracker ()

@property (nonatomic, weak) LoopMeVASTTrackingLinks *links;
@property (nonatomic, strong) NSMutableSet *sentEvents;

@end

@implementation LoopMeVASTEventTracker

- (instancetype)initWithTrackingLinks:(LoopMeVASTTrackingLinks *)trackingLinks {
    self = [super init];
    if (self) {
        _links = trackingLinks;
        _sentEvents = [[NSMutableSet alloc] init];
    }
    return self;
}

- (void)trackEvent:(LoopMeVASTEventType)type {
    if (![self.sentEvents containsObject:@(type)]) {
        NSSet *eventURLs;

        switch (type) {
            case LoopMeVASTEventTypeImpression:
                eventURLs = self.links.impressionLinks;
                break;
            case LoopMeVASTEventTypeLinearStart:
                eventURLs = self.links.linearTrackingLinks.start;
                break;
            case LoopMeVASTEventTypeLinearFirstQuartile:
                eventURLs = self.links.linearTrackingLinks.firstQuartile;
                break;
            case LoopMeVASTEventTypeLinearMidpoint:
                eventURLs = self.links.linearTrackingLinks.midpoint;
                break;
            case LoopMeVASTEventTypeLinearThirdQuartile:
                eventURLs = self.links.linearTrackingLinks.thirdQuartile;
                break;
            case LoopMeVASTEventTypeLinearComplete:
                eventURLs = self.links.linearTrackingLinks.complete;
                break;
            case LoopMeVASTEventTypeLinearClose:
                eventURLs = self.links.linearTrackingLinks.closeLinear;
                break;
            case LoopMeVASTEventTypeLinearPause:
                eventURLs = self.links.linearTrackingLinks.pause;
                break;
            case LoopMeVASTEventTypeLinearResume:
                eventURLs = self.links.linearTrackingLinks.resume;
                break;
            case LoopMeVASTEventTypeLinearExpand:
                eventURLs = self.links.linearTrackingLinks.expand;
                break;
            case LoopMeVASTEventTypeLinearCollapse:
                eventURLs = self.links.linearTrackingLinks.collapse;
                break;
            case LoopMeVASTEventTypeLinearSkip:
                eventURLs = self.links.linearTrackingLinks.skip;
                break;
            case LoopMeVASTEventTypeLinearMute:
                eventURLs = self.links.linearTrackingLinks.mute;
                break;
            case LoopMeVASTEventTypeLinearUnmute:
                eventURLs = self.links.linearTrackingLinks.unmute;
                break;
            case LoopMeVASTEventTypeLinearClickTracking:
                eventURLs = self.links.linearTrackingLinks.clickTracking;
                break;
            case LoopMeVASTEventTypeLinearCreativeView:
                eventURLs = self.links.linearTrackingLinks.creativeView;
                break;
            case LoopMeVASTEventTypeCompanionCreativeView:
                eventURLs = self.links.companionTrackingLinks.creativeView;
                break;
            case LoopMeVASTEventTypeCompanionClickTracking:
                eventURLs = self.links.companionTrackingLinks.clickTracking;
                break;
            default:
                break;
        }
        
        for (NSString *URL in eventURLs) {
            [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:URL]] resume];
        }
        
        [self.sentEvents addObject:@(type)];
    }
}

- (void)trackError:(NSInteger)code {
    NSSet *errorTemplates = self.links.errorLinkTemplates;
    NSError *error = [LoopMeVPAIDError errorForStatusCode:code];
    for (NSString *template in errorTemplates) {
        NSString *errorLink = [template stringByReplacingOccurrencesOfString:@"[ERRORCODE]" withString:[NSString stringWithFormat:@"%li", (long)error.code]];
        NSURL *URL = [NSURL URLWithString:errorLink];
        [[[NSURLSession sharedSession] dataTaskWithURL:URL] resume];
    }
}

- (void)setCurrentTime:(double)currentTime {
    NSSet *events = self.links.linearTrackingLinks.progress;
    for (LoopMeVASTProgressEvent *e in events) {
        if (![self.sentEvents containsObject:@(e.offset.value+60)]) {
            if (currentTime > CMTimeGetSeconds(e.offset)) {
                [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:e.link]] resume];
                [self.sentEvents addObject:@(e.offset.value+60)];
            }
        }
    }
}


@end
