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

@property (nonatomic, weak, nullable) id<LoopMeURLResolverDelegate> delegate;
@property (nonatomic, strong, nonnull) NSURL *URL;

+ (nonnull LoopMeURLResolver *)resolver;
+ (nullable NSString *)storeItemIdentifierForURL:(nonnull NSURL *)URL;
+ (BOOL)mailToForURL:(nonnull NSURL *)URL;
+ (BOOL)telLinkForURL:(nonnull NSURL *)URL;
+ (nullable NSString *)safariURLForURL: (nonnull NSURL *)URL;
- (BOOL)handleURL:(nonnull NSURL *)URL;
- (void)startResolvingWithURL:(nonnull NSURL *)URL delegate:(nonnull id<LoopMeURLResolverDelegate>)delegate;

@end

@protocol LoopMeURLResolverDelegate <NSObject>

- (void)showWebView:(nonnull NSURL *)baseUrl;
- (void)showStoreKitProductWithParameter:(nonnull NSString *)parameter fallbackURL:(nonnull NSURL *)URL;
- (void)openURLInApplication:(nonnull NSURL *)URL;
- (void)failedToResolveURLWithError:(nonnull NSError *)error;

@end
