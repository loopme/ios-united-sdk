//
//  LoopMeAdWebView.h
//  LoopMeSDK
//
//  Created by Dmitriy Lihachov on 8/21/12.
//  Copyright (c) 2012 LoopMe. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface LoopMeAdWebView : WKWebView

- (id)initWithFrame:(CGRect)frame contentController:(WKUserContentController *)controller;

@end
