//
//  LoopMeAdWebView.m
//  LoopMeSDK
//
//  Created by Dmitriy Lihachov on 8/21/12.
//  Copyright (c) 2012 LoopMe. All rights reserved.
//

#import "LoopMeAdWebView.h"

@implementation LoopMeAdWebView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.scalesPageToFit = YES;
        self.userInteractionEnabled = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        self.scrollView.bounces = NO;
        self.scrollView.scrollEnabled = NO;
        self.suppressesIncrementalRendering = YES;
        self.clipsToBounds = NO;
        self.dataDetectorTypes = UIDataDetectorTypeAll;

        if ([self respondsToSelector:@selector(allowsInlineMediaPlayback)]) {
            [self setAllowsInlineMediaPlayback:YES];
            [self setMediaPlaybackRequiresUserAction:NO];
        }
    }
    return self;
}

@end
