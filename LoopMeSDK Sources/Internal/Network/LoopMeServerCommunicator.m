//
//  LoopMeServerCommunicator.m
//  LoopMeSDK
//
//  Created by Dmitriy Lihachov on 07/11/13.
//  Copyright (c) 2013 LoopMe. All rights reserved.
//

#import "LoopMeAdConfiguration.h"
#import "LoopMeDefinitions.h"
#import "LoopMeServerCommunicator.h"
#import "LoopMeError.h"
#import "LoopMeErrorEventSender.h"
#import "LoopMeVPAIDError.h"

const NSTimeInterval kLoopMeAdRequestTimeOutInterval = 20.0;
const NSInteger kLoopMeMaxWrapperNodes = 5;

@interface LoopMeServerCommunicator ()
<
    NSURLSessionTaskDelegate,
    NSURLSessionDataDelegate
>

@property (nonatomic, assign, readwrite, getter = isLoading) BOOL loading;
@property (nonatomic, copy) NSURL *URL;
@property (nonatomic, strong) NSURLSessionDataTask *sessionDataTask;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSString *userAgent;

@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) LoopMeAdConfiguration *configuration;
@property (nonatomic, assign) NSInteger wrapperRequestCounter;

- (void)loadingTaskCompletedSuccessfully:(BOOL)success error:(NSError *)error;

@end

@implementation LoopMeServerCommunicator

#pragma mark - Properties

- (NSString *)userAgent {
    if (_userAgent == nil) {
        _userAgent = [[[UIWebView alloc] init] stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    }
    return _userAgent;
}

#pragma mark - Life Cycle

- (void)dealloc {
    [self.sessionDataTask cancel];
}

- (instancetype)initWithDelegate:(id<LoopMeServerCommunicatorDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
    }
    return self;
}

#pragma mark - Private

- (NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
        configuration.timeoutIntervalForRequest = kLoopMeAdRequestTimeOutInterval;
        configuration.HTTPAdditionalHeaders = @{@"User-Agent" : self.userAgent, @"x-openrtb-version" : @"2.5"};
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    }
    return _session;
}

- (void)loadingTaskCompletedSuccessfully:(BOOL)success error:(NSError *)error {
    self.loading = NO;
    [self.delegate serverCommunicator:self didReceiveAdConfiguration:self.configuration];
    if (success) {
        [self.delegate serverCommunicatorDidReceiveAd:self];
    } else {
        if (error.code == LoopMeErrorCodeIncorrectResponse) {
            [LoopMeErrorEventSender sendError:LoopMeEventErrorTypeBadAsset errorMessage:@"Incorect response" appkey:self.appKey];
        } else {
            [LoopMeErrorEventSender sendError:LoopMeEventErrorTypeBadAsset errorMessage:@"Broken VAST XML" appkey:self.appKey];
        }
        [self.delegate serverCommunicator:self didFailWithError:error];
    }
}

#pragma mark - Public

- (void)loadURL:(NSURL *)URL requestBody:(NSData *)body method:(NSString *)method {
    [self cancel];
    self.URL = URL;
    self.data = [NSMutableData new];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL
                                                           cachePolicy:NSURLRequestReloadIgnoringCacheData
                                                       timeoutInterval:60.0];
    
    if (method) {
        [request setHTTPMethod:method];
    }
    
    if (body) {
        [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:body];
    }
    
    [request setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
    
    self.sessionDataTask = [self.session dataTaskWithRequest:request];
    [self.sessionDataTask resume];
    
    if (!self.configuration.isWrapper) {
        self.configuration = nil;
    }
    self.loading = YES;
}

- (void)cancel {
    self.loading = NO;
    [self.sessionDataTask cancel];
    self.sessionDataTask = nil;
    [self.session invalidateAndCancel];
    self.session = nil;
}

#pragma mark - NSURLSession delegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (error) {
        self.loading = NO;
        if (error.code == -999) {
            return;
        }
        
        if (error.code == 408 || error.code == NSURLErrorTimedOut) {
            [LoopMeErrorEventSender sendError:LoopMeEventErrorTypeServer errorMessage:@"Time out" appkey:[self appKey]];
        } else {
            [LoopMeErrorEventSender sendError:LoopMeEventErrorTypeServer errorMessage:[NSString stringWithFormat:@"Response code: %ld", (long)error.code] appkey:[self appKey]];
        }
        [self.delegate serverCommunicator:self didFailWithError:error];
    } else {
        NSError *parseError;
        
        if (!self.configuration) {
            self.configuration = [[LoopMeAdConfiguration alloc] initWithData:self.data error:&parseError];
        }  else {
            [self.configuration parseXML:[NSData dataWithData:self.data] error:&parseError];
        }
        
        if (parseError && !self.configuration.isWrapper) {
            [self loadingTaskCompletedSuccessfully:NO error:parseError];
            return;
        }
        if ([self.configuration isWrapper]) {
            if (self.wrapperRequestCounter >= kLoopMeMaxWrapperNodes) {
                [self loadingTaskCompletedSuccessfully:NO error:[LoopMeVPAIDError errorForStatusCode:LoopMeVPAIDErrorCodeWrapperLimit]];
                self.wrapperRequestCounter = 0;
                return;
            }
            self.wrapperRequestCounter ++;
            [self loadURL:self.configuration.adTagURL requestBody:nil method:nil];
        } else {
            self.wrapperRequestCounter = 0;
            [self loadingTaskCompletedSuccessfully:YES error:nil];
        }
    }
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [self.data appendData:data];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    
    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
    if (statusCode != 200) {
        if (statusCode != 204) {
            [LoopMeErrorEventSender sendError:LoopMeEventErrorTypeServer errorMessage:[NSString stringWithFormat:@"Response code: %ld", statusCode] appkey:[self appKey]];
        }
        self.loading = NO;
        [self.delegate serverCommunicator:self didFailWithError:[LoopMeError errorForStatusCode:statusCode]];
        
        completionHandler(NSURLSessionResponseCancel);
    } else {
        self.data = nil;
        self.data=[[NSMutableData alloc] init];
        
        completionHandler(NSURLSessionResponseAllow);
    }
}

@end
