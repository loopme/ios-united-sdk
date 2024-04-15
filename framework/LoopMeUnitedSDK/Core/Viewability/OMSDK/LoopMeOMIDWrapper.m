//
//  OMSDKWrapper.m
//  Tester
//
//  Created by Bohdan on 1/23/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

#import <LoopMeUnitedSDK/LoopMeUnitedSDK-Swift.h>
#import "LoopMeOMIDWrapper.h"
#import "LoopMeDefinitions.h"
#import "LoopMeDiscURLCache.h"
#import "LoopMeSDK.h"

typedef void (^CompletionHandlerBlock)(NSData *, NSURLResponse *, NSError *);

static NSString* const PARTNER_NAME = @"Loopme";
static NSString* const CACHE_KEY = @"OMID_JS";
static NSString* const OMID_JS_URL = @"https://i.loopme.me/html/ios/omsdk-v1.js";

@interface LoopMeOMIDWrapper()

@property (nonatomic) NSURLSession *urlSession;
@property (class, nonatomic) NSString *omidJS;
@property (class, nonatomic) OMIDLoopmePartner *partner;
@property (nonatomic) OMIDLoopmeAdSessionConfiguration *configuration;
@property (nonatomic) NSMutableArray *scripts;

@end

@implementation LoopMeOMIDWrapper
static NSString *_omidJS;
static BOOL _activatedBlockCalled;
static OMIDLoopmePartner *_partner;

@dynamic omidJS;
@dynamic partner;

- (instancetype)init {
    self = [super init];
    if (self) {
        _scripts = [NSMutableArray new];
    }
    return self;
}

+ (NSString *)omidJS {
    return _omidJS;
}

+ (void)setOmidJS:(NSString *)omidJS {
    _omidJS = omidJS;
}

+ (OMIDLoopmePartner *)partner {
    return _partner;
}

+ (void)setPartner:(OMIDLoopmePartner *)partner {
    _partner = partner;
}

+ (BOOL)initOMIDWithCompletionBlock:(void (^)(BOOL))completionBlock {
    NSError *error;
    BOOL sdkStarted = [[OMIDLoopmeSDK sharedInstance] activate];
    
    if (!sdkStarted || error) {
        completionBlock(NO);
        _activatedBlockCalled = YES;
        return NO;
    }
    
    [self loadJSWithCompletionBlock:^(BOOL completed) {
        if (!_activatedBlockCalled) {
            completionBlock(completed);
        }
        _activatedBlockCalled = YES;
    }];
    
    [self initPartner];
    
    return YES;
}

+ (void)loadJSWithCompletionBlock:(void (^)(BOOL))completionBlock {
    __weak typeof(self) weakSelf = self;

    if (!self.class.omidJS) {
        NSData *data = [[LoopMeDiscURLCache sharedDiscCache] retrieveDataForKey: CACHE_KEY];
        if (data) {
            self.class.omidJS = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
        }
        
        if (self.class.omidJS) {
            completionBlock(true);
        }
    }
    
    CompletionHandlerBlock completionHandler = ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || weakSelf == nil) {
            return completionBlock(false);
        }

        [[LoopMeDiscURLCache sharedDiscCache] storeData: data forKey: CACHE_KEY];
        if (!weakSelf.class.omidJS) {
            weakSelf.class.omidJS = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
        }
        completionBlock(true);
    };
    NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString: OMID_JS_URL]
                                             cachePolicy: NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval: 5];
    [[[NSURLSession sharedSession] dataTaskWithRequest: request completionHandler: completionHandler] resume];
}

+ (void)initPartner {
    self.partner = [[OMIDLoopmePartner alloc] initWithName: PARTNER_NAME versionString: LOOPME_SDK_VERSION];
}

#pragma mark - public

- (NSString *)injectScriptContentIntoHTML: (NSString *)htmlString
                                    error: (NSError **)error {
    return [OMIDLoopmeScriptInjector injectScriptContent: self.class.omidJS
                                                intoHTML: htmlString
                                                   error: error];
}

- (OMIDLoopmeAdSessionContext *)contextForHTML: (UIView *)webView
                                         error: (NSError **)error {
    return [[OMIDLoopmeAdSessionContext alloc] initWithPartner: self.class.partner
                                                       webView: webView
                                                    contentUrl: nil
                                     customReferenceIdentifier: @""
                                                         error: error];
}


// TODO: Move to more proper place. It's just a converter
- (NSMutableArray *)toOmidResources: (NSArray<LoopMeAdVerification *> *) resources {
    NSMutableArray *omidResources = [NSMutableArray new];
    for (LoopMeAdVerification *verification in resources) {
        NSURL *resourceURL = [NSURL URLWithString: [verification jsResource]];
        NSString *params = [verification verificationParameters] ?: @"";
        
        OMIDLoopmeVerificationScriptResource *omidResource = [OMIDLoopmeVerificationScriptResource alloc];
        
        [omidResources addObject: [params isEqualToString:@""] ?
         [omidResource initWithURL: resourceURL] :
         [omidResource initWithURL: resourceURL vendorKey: [verification vendor] ?: @"" parameters: params]];
    }
    return omidResources;
}

- (OMIDLoopmeAdSessionContext *)contextForNativeVideo: (NSArray<LoopMeAdVerification *> *) resources
                                                error: (NSError **)error {
    
    return [[OMIDLoopmeAdSessionContext alloc] initWithPartner: self.class.partner
                                                        script: self.class.omidJS
                                                     resources: [self toOmidResources: resources ?: [NSArray array]]
                                                    contentUrl: nil
                                     customReferenceIdentifier: @""
                                                         error: error];
    
}

- (OMIDLoopmeAdSessionConfiguration *)configurationFor: (OMIDCreativeType)creativeType {
    NSError *cfgError;
    return [[OMIDLoopmeAdSessionConfiguration alloc] initWithCreativeType: creativeType
                                                           impressionType: OMIDImpressionTypeBeginToRender
                                                          impressionOwner: OMIDNativeOwner
                                                         mediaEventsOwner: OMIDNoneOwner
                                               isolateVerificationScripts: NO
                                                                    error: &cfgError];
}

- (OMIDLoopmeAdSession *)sessionFor: (OMIDLoopmeAdSessionConfiguration *) configuration
                            context: (OMIDLoopmeAdSessionContext *)context
                              error: (NSError **)error {
    // TODO: Check where self.configuration is used also
    self.configuration = configuration;
    if (*error != nil) {
        return nil;
    }
    return [[OMIDLoopmeAdSession alloc] initWithConfiguration: configuration
                                             adSessionContext: context
                                                        error: error];
}

- (OMIDLoopmeAdSession *)sessionForHTML: (UIView *)webView
                                  error: (NSError **)error {
    return [self sessionFor: [self configurationFor: OMIDCreativeTypeHtmlDisplay]
                    context: [self contextForHTML: webView error: error]
                      error: error];
}

- (OMIDLoopmeAdSession *)sessionForNativeVideo: (NSArray<LoopMeAdVerification *> *) resources
                                         error: (NSError **)error {
    return [self sessionFor: [self configurationFor: OMIDCreativeTypeVideo]
                    context: [self contextForNativeVideo: resources error: error]
                      error: error];
}

@end
