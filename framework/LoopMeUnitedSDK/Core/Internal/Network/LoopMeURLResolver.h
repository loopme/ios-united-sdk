//
//  LoopMeURLResolver.h
//  LoopMeSDK
//
//  Created by Dmitriy Lihachov on 11/11/13.
//  Copyright (c) 2013 LoopMe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol LoopMeURLResolverDelegate;

@interface LoopMeURLResolver : NSObject
<
    NSURLConnectionDataDelegate
>

@property (nonatomic, weak) id<LoopMeURLResolverDelegate> delegate;

+ (LoopMeURLResolver *)resolver;
+ (NSString *)storeItemIdentifierForURL:(NSURL *)URL;
+ (BOOL)mailToForURL:(NSURL *)URL;
+ (BOOL)telLinkForURL:(NSURL *)URL;

- (void)startResolvingWithURL:(NSURL *)URL delegate:(id<LoopMeURLResolverDelegate>)delegate;
- (void)cancel;

@end

@protocol LoopMeURLResolverDelegate <NSObject>

- (void)showWebViewWithHTMLString:(NSString *)HTMLString baseURL:(NSURL *)URL;
- (void)showStoreKitProductWithParameter:(NSString *)parameter fallbackURL:(NSURL *)URL;
- (void)openURLInApplication:(NSURL *)URL;
- (void)failedToResolveURLWithError:(NSError *)error;

@end
