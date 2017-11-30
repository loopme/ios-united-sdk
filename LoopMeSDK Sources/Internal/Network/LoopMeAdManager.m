//
//  LoopMeInterstitialManager.m
//  LoopMeSDK
//
//  Created by Dmitriy Lihachov on 07/11/13.
//  Copyright (c) 2013 LoopMe. All rights reserved.
//

#import "LoopMeAdManager.h"
#import "LoopMeServerURLBuilder.h"
#import "LoopMeServerCommunicator.h"
#import "LoopMeAdConfiguration.h"
#import "LoopMeDefinitions.h"
#import "LoopMeInterstitialViewController.h"
#import "LoopMeAdDisplayControllerNormal.h"
#import "LoopMeLogging.h"
#import "LoopMeORTBTools.h"

NSString * const kLoopMeAPIURL = @"https://loopme.me/api/ortb/ads";

@interface LoopMeAdManager ()
<
    LoopMeServerCommunicatorDelegate
>

@property (nonatomic, strong) LoopMeServerCommunicator *communicator;
@property (nonatomic, assign, readwrite, getter = isReady) BOOL ready;
@property (nonatomic, assign, readwrite, getter = isLoading) BOOL loading;

@property (nonatomic, strong) NSTimer *adExpirationTimer;
@property (nonatomic, assign) NSInteger expirationTime;
@property (nonatomic, strong) NSString *appKey;

@end

@implementation LoopMeAdManager

#pragma mark - Life Cycle

- (void)dealloc {
    [_adExpirationTimer invalidate];
    _adExpirationTimer = nil;
    
    [_communicator cancel];    
}

- (instancetype)initWithDelegate:(id<LoopMeAdManagerDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        _communicator = [[LoopMeServerCommunicator alloc] initWithDelegate:self];
    }
    return self;
}

#pragma mark - Private

- (void)loadAdWithURL:(NSURL *)URL requestBody:(NSData *)body {
    if (self.isLoading) {
        LoopMeLogInfo(@"Interstitial is already loading an ad. Wait for previous load to finish");
        return;
    }

    self.loading = YES;
    LoopMeLogInfo(@"Did start loading ad");
    LoopMeLogDebug(@"loads ad with URL %@", [URL absoluteString]);
    [self.communicator loadURL:URL requestBody:body];
}

- (void)scheduleAdExpirationIn:(NSTimeInterval)interval {
    self.adExpirationTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                            target:self
                                                          selector:@selector(adContentBecameExpired)
                                                          userInfo:nil
                                                           repeats:NO];
}

- (void)adContentBecameExpired {
    [self invalidateTimers];
    LoopMeLogDebug(@"Ad content is expired");
    if ([self.delegate respondsToSelector:@selector(adManagerDidExpireAd:)]) {
        [self.delegate adManagerDidExpireAd:self];
    }
}

#pragma mark - Public

- (void)loadAdWithAppKey:(NSString *)appKey targeting:(LoopMeTargeting *)targeting
         integrationType:(NSString *)integrationType adSpotSize:(CGSize)size {
    
    self.appKey = appKey;
    self.communicator.appKey = appKey;
    NSData *requestBody = [LoopMeORTBTools makeRequestBodyWithAppKey:appKey targeting:targeting integrationType:integrationType adSpotSize:size];
    
    if (self.testServerBaseURL) {
        #pragma mark TODO: make request
        [self loadAdWithURL:[NSURL URLWithString:kLoopMeAPIURL] requestBody:requestBody];
    } else {
        [self loadAdWithURL:[NSURL URLWithString:kLoopMeAPIURL] requestBody:requestBody];
    }
}

- (void)invalidateTimers {
    [self.adExpirationTimer invalidate];
    self.adExpirationTimer = nil;
}

#pragma mark - LoopMeServerCommunicatorDelegate

- (void)serverCommunicator:(LoopMeServerCommunicator *)communicator didReceiveAdConfiguration:(LoopMeAdConfiguration *)adConfiguration {
    LoopMeLogDebug(@"Did receive ad configuration: %@", adConfiguration);
    adConfiguration.appKey = self.appKey;
    self.expirationTime = adConfiguration.expirationTime;
    if ([self.delegate respondsToSelector:@selector(adManager:didReceiveAdConfiguration:)]) {
        [self.delegate adManager:self didReceiveAdConfiguration:adConfiguration];
    }
    self.loading = NO;
//    [self scheduleAdExpirationIn:adConfiguration.expirationTime];
}

- (void)serverCommunicatorDidReceiveAd:(LoopMeServerCommunicator *)communicator {
    if ([self.delegate respondsToSelector:@selector(adManagerDidReceiveAd:)]) {
        [self.delegate adManagerDidReceiveAd:self];
    }
    self.loading = NO;
    [self scheduleAdExpirationIn:self.expirationTime];
}

- (void)serverCommunicator:(LoopMeServerCommunicator *)communicator didFailWithError:(NSError *)error {
    self.loading = NO;
    LoopMeLogDebug(@"Ad failed to load with error: %@", error);
    
    if ([self.delegate respondsToSelector:@selector(adManager:didFailToLoadAdWithError:)]) {
        [self.delegate adManager:self didFailToLoadAdWithError:error];
    }
}

@end
