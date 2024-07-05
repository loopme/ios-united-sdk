//
//  LoopMeURLResolver.m
//  LoopMeSDK
//
//  Created by Dmitriy Lihachov on 11/11/13.
//  Copyright (c) 2013 LoopMe. All rights reserved.
//

#import "LoopMeDefinitions.h"
#import "LoopMeURLResolver.h"
#import "NSURL+LoopMeAdditions.h"
#import "LoopMeError.h"

@implementation LoopMeURLResolver

#pragma mark - Class Methods

+ (nonnull LoopMeURLResolver *)resolver {
    return [[LoopMeURLResolver alloc] init];
}

+ (nullable NSString *)storeItemIdentifierForURL: (nonnull NSURL *)URL {
    NSString *itemIdentifier = nil;
    if ([URL.host hasSuffix: @"itunes.apple.com"]) {
        NSString *lastPathComponent = [[URL path] lastPathComponent];
        itemIdentifier = [lastPathComponent hasPrefix: @"id"] ? [lastPathComponent substringFromIndex: 2] : URL.lm_toDictionary[@"id"];
    } else if ([URL.host hasSuffix: @"photos.apple.com"]) {
        itemIdentifier = URL.lm_toDictionary[@"id"];
    }
    
    NSCharacterSet *nonIntegers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    if (itemIdentifier && itemIdentifier.length > 0 && [itemIdentifier rangeOfCharacterFromSet: nonIntegers].location == NSNotFound) {
        return itemIdentifier;
    }
    
    return nil;
}

+ (BOOL)mailToForURL: (nonnull NSURL *)URL {
    return [URL.absoluteString hasPrefix: @"mailto:"];
}

+ (BOOL)telLinkForURL: (nonnull NSURL *)URL {
    return [URL.absoluteString hasPrefix: @"tel:"];
}

+ (nullable NSString *)safariURLForURL: (nonnull NSURL *)URL {
    NSString * const kLoopMeSafariScheme = @"loopmenativebrowser";
    NSString * const kLoopMeSafariNavigateHost = @"navigate";
    BOOL isSafariUrl = [[URL scheme] isEqualToString: kLoopMeSafariScheme] && [[URL host] isEqualToString: kLoopMeSafariNavigateHost];
    return isSafariUrl ? (URL.lm_toDictionary)[@"url"] : nil;
}

#pragma mark - Private

- (BOOL)handleURL: (nonnull NSURL *)URL {
    NSString *itemIdentifier = [LoopMeURLResolver storeItemIdentifierForURL: URL];
    if (itemIdentifier) {
        [self.delegate showStoreKitProductWithParameter: itemIdentifier fallbackURL: URL];
        return YES;
    }
    
    NSString *safariUrl = [LoopMeURLResolver safariURLForURL: URL];
    if (safariUrl) {
        [self.delegate openURLInApplication: [NSURL URLWithString: safariUrl]];
        return YES;
    }
    
    BOOL isHttpOrHttps = [URL.scheme isEqualToString: @"http"] || [URL.scheme isEqualToString: @"https"];
    BOOL isPointsToMap = [URL.host hasSuffix: @"maps.google.com"] || [URL.host hasSuffix: @"maps.apple.com"];
    
    if (!isHttpOrHttps || isPointsToMap) {
        if ([[UIApplication sharedApplication] canOpenURL: URL]) {
            [self.delegate openURLInApplication: URL];
        } else {
            [self.delegate failedToResolveURLWithError: [LoopMeError errorForStatusCode: LoopMeErrorCodeURLResolve]];
        }
        return YES;
    }
    
    return NO;
}

#pragma mark - Public

- (void)startResolvingWithURL: (nonnull NSURL *)URL delegate: (nonnull id<LoopMeURLResolverDelegate>)delegate {
    self.URL = URL;
    self.delegate = delegate;

    if (![self handleURL: self.URL]) {
        [self.delegate showWebView: self.URL];
    }
}
@end
