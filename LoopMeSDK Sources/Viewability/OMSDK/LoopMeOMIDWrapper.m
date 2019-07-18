//
//  OMSDKWrapper.m
//  Tester
//
//  Created by Bohdan on 1/23/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

#import "LoopMeOMIDWrapper.h"
#import "LoopMeDefinitions.h"
#import "LoopMeDiscURLCache.h"

static NSString* const PARTNER_NAME = @"Loopme";
static NSString* const CACHE_KEY = @"OMID_JS";

@interface LoopMeOMIDWrapper()

@property (nonatomic) NSURLSession *urlSession;
@property (class, nonatomic) NSString *omidJS;
@property (class, nonatomic) OMIDLoopmePartner *partner;
@property (nonatomic) OMIDLoopmeAdSessionConfiguration *configuration;
@property (nonatomic) NSMutableArray *scripts;

@end

@implementation LoopMeOMIDWrapper
static NSString *_omidJS;
static OMIDLoopmePartner *_partner;

@dynamic omidJS;
@dynamic partner;

- (instancetype)init
{
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
    BOOL sdkStarted = [[OMIDLoopmeSDK sharedInstance] activateWithOMIDAPIVersion:OMIDSDKAPIVersionString error:&error];
    
    if (!sdkStarted || error) {
        completionBlock(false);
        return NO;
    }
    
    [self loadJSWithCompletionBlock:^(BOOL completed) {
        completionBlock(completed);
    }];
    
    [self initPartner];
    
    return YES;
}

+ (void)loadJSWithCompletionBlock:(void (^)(BOOL))completionBlock {
    if (!self.class.omidJS) {
        NSData *data = [[LoopMeDiscURLCache sharedDiscCache] retrieveDataForKey:CACHE_KEY];
        self.class.omidJS = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if (self.class.omidJS) {
            completionBlock(true);
        }
    }

    NSURL *url = [NSURL URLWithString:@"https://i.loopme.me/html/ios/omsdk-v1.js"];
    __weak typeof(self) weakSelf = self;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:5];
    NSURLSession *defaultSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:request
                                                   completionHandler:^(NSData *data, NSURLResponse
                                                                       *response, NSError *error) {
                                                       if (error || weakSelf == nil) {
                                                           completionBlock(false);
                                                           return;
                                                       }

                                                       [[LoopMeDiscURLCache sharedDiscCache] storeData:data forKey:CACHE_KEY];
                                                       if (!weakSelf.class.omidJS) {
                                                           weakSelf.class.omidJS = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                       }
                                                       completionBlock(true);
                                                   }];
    [dataTask resume];
}

+ (void)initPartner {
    self.partner = [[OMIDLoopmePartner alloc] initWithName:PARTNER_NAME
                                                 versionString:LOOPME_SDK_VERSION];
}

#pragma mark - public

- (NSString *)injectScriptContentIntoHTML:(NSString *)htmlString error:(NSError **)error {
    NSString *finalString = [OMIDLoopmeScriptInjector injectScriptContent:self.class.omidJS
                                                        intoHTML:htmlString error:error];
    
    return finalString;
}

- (OMIDLoopmeAdSessionContext *)contextForType:(OMIDLoopmeCreativeType)creativeType
                                       webView:(UIView *)webView
                                     resources:(NSArray<LoopMeVerification *> *) resources
                                         error:(NSError **)error {
    // the custom reference ID may not be relevant to your integration in which case you may pass an
    // empty string.
    NSString *customRefId = @"";
    NSMutableArray *omidResources;
    if (resources) {
        omidResources = [[NSMutableArray alloc] init];
        for (LoopMeVerification *verification in resources) {
            NSURL *respurceURL = [NSURL URLWithString:[verification resource]];
            NSString *vendorKey = [verification vendorKey] != nil ? [verification vendorKey] : @"";
            NSString *params = [verification params] != nil ? [verification params] : @"";
            
            OMIDLoopmeVerificationScriptResource *omidResource = [[OMIDLoopmeVerificationScriptResource alloc] initWithURL:respurceURL vendorKey:vendorKey parameters:params];
            if (omidResource) {
                [omidResources addObject:omidResource];
            }
        }
    }
    
    OMIDLoopmeAdSessionContext *context;
    switch (creativeType) {
        case OMIDLoopmeCreativeTypeHTML:
            context = [[OMIDLoopmeAdSessionContext alloc] initWithPartner:self.class.partner
                                                                    webView:webView customReferenceIdentifier:customRefId error:error];
            break;
        case OMIDLoopmeCreativeTypeNativeVideo:
            
            
            context = [[OMIDLoopmeAdSessionContext alloc]
                       initWithPartner:self.class.partner
                       script:self.class.omidJS resources:omidResources customReferenceIdentifier:customRefId error:error];
            break;
        default:
            break;
    }
    
    
    return context;
}

- (OMIDLoopmeAdSessionConfiguration *)configurationForType:(OMIDLoopmeCreativeType)creativeType {
    OMIDLoopmeAdSessionConfiguration *config;
    NSError *cfgError;
    switch (creativeType) {
        case OMIDLoopmeCreativeTypeHTML:
            config = [[OMIDLoopmeAdSessionConfiguration alloc]
                        initWithImpressionOwner:OMIDNativeOwner videoEventsOwner:OMIDNoneOwner
                        isolateVerificationScripts:NO error:&cfgError];
            break;
        case OMIDLoopmeCreativeTypeNativeVideo:
            config = [[OMIDLoopmeAdSessionConfiguration alloc]
                                                  initWithImpressionOwner:OMIDNativeOwner videoEventsOwner:OMIDNativeOwner
                                                  isolateVerificationScripts:NO error:&cfgError];
            break;
        default:
            break;
    }
    
    
    
    return config;
}

- (OMIDLoopmeAdSession *)sessionForType:(OMIDLoopmeCreativeType)creativeType
                              resources:(NSArray<LoopMeVerification *> *) resources
                                webView:(UIView *)webView
                                  error:(NSError **)error {
    
    OMIDLoopmeAdSessionContext *context = [self contextForType:creativeType
                                                       webView:webView
                                                        resources:resources
                                                         error:error];
    
    self.configuration = [self configurationForType:creativeType];
    
    if (*error != nil) {
        return nil;
    }
    OMIDLoopmeAdSession *omidSession = [[OMIDLoopmeAdSession alloc] initWithConfiguration:self.configuration
                                                   adSessionContext:context error:error];
    
    if (*error != nil) {
        return nil;
    }
    
    return omidSession;
}

@end
