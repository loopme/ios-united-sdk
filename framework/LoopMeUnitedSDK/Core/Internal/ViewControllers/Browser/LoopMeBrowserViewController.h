//
//  LoopMeBrowserViewController
//  LoopMeSDK
//
//  Created by Dmitriy Lihachov on 8/21/12.
//  Copyright (c) 2012 LoopMe. All rights reserved.
//

#import <WebKit/WebKit.h>
@class LoopMeBrowserViewController;

@protocol LoopMeBrowserControllerDelegate;
@protocol WKNavigationDelegate;
@protocol WKUIDelegate;

@interface LoopMeBrowserViewController : UIViewController
<
    WKNavigationDelegate,
    WKUIDelegate,
    UIActionSheetDelegate
>

@property (nonatomic, weak) id<LoopMeBrowserControllerDelegate> delegate;
@property (nonatomic, copy) NSURL *URL;

- (instancetype)initWithURL:(NSURL *)URL
       HTMLString:(NSString *)HTMLString
         delegate:(id<LoopMeBrowserControllerDelegate>)delegate;

@end

@protocol LoopMeBrowserControllerDelegate

- (void)dismissBrowserController:(LoopMeBrowserViewController *)browserController
                        animated:(BOOL)animated;

@end
