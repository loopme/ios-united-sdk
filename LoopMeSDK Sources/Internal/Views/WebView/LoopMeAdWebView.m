//
//  LoopMeAdWebView.m
//  LoopMeSDK
//
//  Created by Dmitriy Lihachov on 8/21/12.
//  Copyright (c) 2012 LoopMe. All rights reserved.
//

#import "LoopMeAdWebView.h"

@implementation LoopMeAdWebView

- (id)initWithFrame:(CGRect)frame contentController:(WKUserContentController *)controller {
    WKWebViewConfiguration *conf = [[WKWebViewConfiguration alloc] init];
    conf.allowsInlineMediaPlayback = YES;
    conf.mediaTypesRequiringUserActionForPlayback = NO;
    conf.userContentController = controller;
    
    self = [super initWithFrame:frame configuration:conf];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
//        self.scalesPageToFit = NO;
        self.userInteractionEnabled = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        self.scrollView.bounces = NO;
        self.scrollView.scrollEnabled = NO;
//        self.suppressesIncrementalRendering = NO;
        self.clipsToBounds = NO;
//        self.dataDetectorTypes = UIDataDetectorTypeAll;

       
//        if ([self respondsToSelector:@selector(allowsInlineMediaPlayback)]) {
//            [self setAllowsInlineMediaPlayback:YES];
//            [self setMediaPlaybackRequiresUserAction:NO];
//        }
    }
    return self;
}

//- (void)setContentController:(WKUserContentController *)controller {
//    WKWebViewConfiguration *configuration = self.configuration;
//    configuration.userContentController = controller;
//    se
//}

@end
