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

+ (WKWebViewConfiguration *)sharedConfiguration {
    static WKWebViewConfiguration *sharedConf = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedConf = [[WKWebViewConfiguration alloc] init];
        sharedConf.allowsInlineMediaPlayback = YES;
        sharedConf.mediaTypesRequiringUserActionForPlayback = NO;
    });
    return sharedConf;
}

- (id)initWithFrame:(CGRect)frame contentController:(WKUserContentController *)controller {
    WKWebViewConfiguration *conf = [LoopMeAdWebView sharedConfiguration];
    conf.userContentController = controller; 

    self = [super initWithFrame:frame configuration:conf];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        self.userInteractionEnabled = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        self.scrollView.bounces = NO;
        self.scrollView.scrollEnabled = NO;
        self.clipsToBounds = NO;
    }
    return self;
}

- (void)dealloc {
    self.scrollView.delegate = nil;
}

@end
