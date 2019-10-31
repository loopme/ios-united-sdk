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

static NSString * const kLoopMeSafariScheme = @"loopmenativebrowser";
static NSString * const kLoopMeSafariNavigateHost = @"navigate";

@interface LoopMeURLResolver ()

@property (nonatomic, strong) NSURL *URL;

- (BOOL)handleURL:(NSURL *)URL;
- (BOOL)URLShouldOpenInApplication:(NSURL *)URL;
- (BOOL)URLIsHTTPOrHTTPS:(NSURL *)URL;
- (BOOL)URLPointsToAMap:(NSURL *)URL;

@end

@implementation LoopMeURLResolver

#pragma mark - Class Methods 

- (void)dealloc {
    
}

+ (LoopMeURLResolver *)resolver {
    return [[LoopMeURLResolver alloc] init];
}

+ (NSString *)storeItemIdentifierForURL:(NSURL *)URL {
    NSString *itemIdentifier = nil;
    if ([URL.host hasSuffix:@"itunes.apple.com"]) {
        NSString *lastPathComponent = [[URL path] lastPathComponent];
        if ([lastPathComponent hasPrefix:@"id"]) {
            itemIdentifier = [lastPathComponent substringFromIndex:2];
        } else {
            itemIdentifier = (URL.lm_toDictionary)[@"id"];
        }
    } else if ([URL.host hasSuffix:@"phobos.apple.com"]) {
        itemIdentifier = (URL.lm_toDictionary)[@"id"];
    }
    
    NSCharacterSet *nonIntegers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    if (itemIdentifier && itemIdentifier.length > 0 && [itemIdentifier rangeOfCharacterFromSet:nonIntegers].location == NSNotFound) {
        return itemIdentifier;
    }
    
    return nil;
}

+ (BOOL)mailToForURL:(NSURL *)URL {
    return [URL.absoluteString hasPrefix:@"mailto:"] ? YES : NO;
}

+ (BOOL)telLinkForURL:(NSURL *)URL {
    return [URL.absoluteString hasPrefix:@"tel:"] ? YES : NO;
}

+ (NSString *)safariURLForURL:(NSURL *)URL {
    NSString *safariURL = nil;
    
    if ([[URL scheme] isEqualToString:kLoopMeSafariScheme] &&
        [[URL host] isEqualToString:kLoopMeSafariNavigateHost]) {
        safariURL = (URL.lm_toDictionary)[@"url"];
    }
    
    return safariURL;
}

#pragma mark - Private

- (BOOL)handleURL:(NSURL *)URL {
    if ([LoopMeURLResolver storeItemIdentifierForURL:URL]) {
        [self.delegate showStoreKitProductWithParameter:[LoopMeURLResolver storeItemIdentifierForURL:URL] fallbackURL:URL];
    } else if ([LoopMeURLResolver safariURLForURL:URL]) {
        NSURL *safariURL = [NSURL URLWithString:[LoopMeURLResolver safariURLForURL:URL]];
        [self.delegate openURLInApplication:safariURL];
    } else if ([self URLShouldOpenInApplication:URL]) {
        if ([[UIApplication sharedApplication] canOpenURL:URL]) {
            [self.delegate openURLInApplication:URL];
        } else {
            [self.delegate failedToResolveURLWithError:[LoopMeError errorForStatusCode:LoopMeErrorCodeURLResolve]];
        }
    } else {
        return NO;
    }
    return YES;
}

#pragma mark Resolve URLs

- (BOOL)URLShouldOpenInApplication:(NSURL *)URL {
    return ![self URLIsHTTPOrHTTPS:URL] || [self URLPointsToAMap:URL];
}

- (BOOL)URLIsHTTPOrHTTPS:(NSURL *)URL {
    return [URL.scheme isEqualToString:@"http"] || [URL.scheme isEqualToString:@"https"];
}

- (BOOL)URLPointsToAMap:(NSURL *)URL {
    return [URL.host hasSuffix:@"maps.google.com"] || [URL.host hasSuffix:@"maps.apple.com"];
}


#pragma mark - Public

- (void)startResolvingWithURL:(NSURL *)URL delegate:(id<LoopMeURLResolverDelegate>)delegate {
    self.URL = URL;
    self.delegate = delegate;

    if (![self handleURL:self.URL]) {
        [self.delegate showWebViewWithHTMLString:nil
                                         baseURL:self.URL];
    }
}

- (void)cancel {

}

@end
