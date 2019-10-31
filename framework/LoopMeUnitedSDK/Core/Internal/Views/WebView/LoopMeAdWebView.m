//
//  LoopMeAdWebView.m
//  LoopMeSDK
//
//  Created by Dmitriy Lihachov on 8/21/12.
//  Copyright (c) 2012 LoopMe. All rights reserved.
//

#import "LoopMeAdWebView.h"

@interface LoopMeAdWebView ()

@end

@implementation LoopMeAdWebView

- (id)initWithFrame:(CGRect)frame contentController:(WKUserContentController *)controller {
    WKWebViewConfiguration *conf = [[WKWebViewConfiguration alloc] init];
    conf.allowsInlineMediaPlayback = YES;
    conf.mediaTypesRequiringUserActionForPlayback = NO;
    conf.userContentController = controller;
    
    self = [super initWithFrame:frame configuration:conf];
    if (self) {
        self.scrollView.delegate = self;
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.userInteractionEnabled = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        self.scrollView.bounces = NO;
        self.scrollView.scrollEnabled = NO;
        self.clipsToBounds = NO;
//        self.dataDetectorTypes = UIDataDetectorTypeAll;

    }
    return self;
}

- (void)dealloc {
    self.scrollView.delegate = nil;
}

@end
