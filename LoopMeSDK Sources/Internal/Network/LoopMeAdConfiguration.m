//
//  LoopMeAdConfiguration.m
//  LoopMeSDK
//
//  Created by Dmitriy Lihachov on 07/11/13.
//  Copyright (c) 2013 LoopMe. All rights reserved.

#import "LoopMeGlobalSettings.h"
#import "LoopMeAdConfiguration.h"
#import "LoopMeLogging.h"
#import "LoopMeGlobalSettings.h"
#import "LoopMeDefinitions.h"
#import "LoopMeError.h"

const int kLoopMeExpireTimeIntervalMinimum = 600;

// Events
const struct LoopMeTrackerNameStruct LoopMeTrackerName = {
    .moat = @"moat",
    .dv = @"dv",
    .ias = @"ias"
};

@interface LoopMeAdConfiguration ()

@property (nonatomic) NSArray *measurePartners;
@property (nonatomic) NSDictionary *jsonMacroses;

@end

@implementation LoopMeAdConfiguration

#pragma mark - Life Cycle

- (void)dealloc {
    
}

- (instancetype)initWithData:(NSData *)data error:(NSError **)error{
    self = [super init];
    if (self) {
//        NSError *error = nil;
        NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                           options:kNilOptions
                                                                             error:error];
        if (error != NULL && *error) {
            LoopMeLogError(@"Failed to parse ad response, error: %@", *error);
            *error = [LoopMeError errorForStatusCode:LoopMeErrorCodeIncorrectResponse];
            return nil;
        }
        
        _trackingLinks = [[LoopMeVASTTrackingLinks alloc] init];
        _assetLinks = [[LoopMeVASTAssetLinks alloc] init];
        _eventTracker = [[LoopMeVASTEventTracker alloc] initWithTrackingLinks:self.trackingLinks];
        
        NSDictionary *bid;
        @try {
            bid = responseDictionary[@"seatbid"][0][@"bid"][0];
            _creativeContent = bid[@"adm"];
            
            NSString *crtp = bid[@"ext"][@"crtype"];
            if ([crtp isEqualToString:@"VAST"]) {
                _creativeType = LoopMeCreativeTypeVAST;
            } else if ([crtp containsString:@"MRAID"]) {
                _creativeType = LoopMeCreativeTypeMRAID;
            } else {
                _creativeType = LoopMeCreativeTypeNormal;
            }
        } @catch (NSException *exception) {
            LoopMeLogError(@"Incorect response: %@", exception.description);
            *error = [LoopMeError errorForStatusCode:LoopMeErrorCodeIncorrectResponse];
            return nil;
        }

        NSData *creativeData = [_creativeContent dataUsingEncoding:NSUTF8StringEncoding];
        if (_creativeType == LoopMeCreativeTypeVAST) {
            [self parseXML:creativeData error:error];
        }
        [self mapAdConfigurationFromDictionary:bid[@"ext"]];
        [self initAdIDS:bid];
    }
    return self;
}

- (BOOL)isPortrait {
    return self.orientation == LoopMeAdOrientationPortrait;
}

- (BOOL)isVPAID {
    return !!self.assetLinks.vpaidURL;
}

#pragma mark - Private

- (void)initAdIDS:(NSDictionary *)bid {
    NSDictionary *jsonMacroses = bid[@"ext"];
    
    _adIdsForMOAT = [NSDictionary dictionaryWithObjectsAndKeys:[[jsonMacroses objectForKey:kLoopMeAdvertiser] stringByRemovingPercentEncoding], @"level1", [[jsonMacroses objectForKey:kLoopMeCampaign] stringByRemovingPercentEncoding], @"level2", [[jsonMacroses objectForKey:kLoopMeLineItem] stringByRemovingPercentEncoding], @"level3", [[bid objectForKey:kLoopMeCreative] stringByRemovingPercentEncoding], @"level4", [[jsonMacroses objectForKey:kLoopMeAPP] stringByRemovingPercentEncoding], @"slicer1", @"", @"slicer2",  nil];
    
    
    NSString *placemantid = [NSString stringWithFormat:@"%@_%@", [[self.jsonMacroses objectForKey:kLoopMeAPP] stringByRemovingPercentEncoding],  self.appKey];
    
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier] != nil ? [[NSBundle mainBundle] bundleIdentifier] : @"unknown";
    
    NSString *anId = kLoopMeIASAnID;
    NSString *pubId = [NSString stringWithFormat:@"%@_%@", [[self.jsonMacroses objectForKey:kLoopMeCompany] stringByRemovingPercentEncoding], [[self.jsonMacroses objectForKey:kLoopMeDeveloper] stringByRemovingPercentEncoding]];
    
    _adIdsForIAS = [NSDictionary dictionaryWithObjectsAndKeys: anId, @"anId", [[self.jsonMacroses objectForKey:kLoopMeAdvertiser] stringByRemovingPercentEncoding], @"advId", [[self.jsonMacroses objectForKey:kLoopMeCampaign] stringByRemovingPercentEncoding], @"campId", pubId, @"pubId", bundleIdentifier, @"chanId", placemantid, @"placementId", bundleIdentifier, @"bundleId",  nil];
}

- (void)mapAdConfigurationFromDictionary:(NSDictionary *)dictionary {
    [self setPreload25:[[dictionary objectForKey:@"preload25"] boolValue]];
    [self setV360:[[dictionary objectForKey:@"v360"] boolValue]];

    _expirationTime = [dictionary[@"ad_expiry_time"] integerValue];
    if (_expirationTime < kLoopMeExpireTimeIntervalMinimum) {
        _expirationTime = kLoopMeExpireTimeIntervalMinimum;
    }

    if ([dictionary objectForKey:@"debug"]) {
        [LoopMeGlobalSettings sharedInstance].liveDebugEnabled = [dictionary[@"debug"] boolValue];
    }

    if ([dictionary[@"orientation"] isEqualToString:@"portrait"]) {
        _orientation = LoopMeAdOrientationPortrait;
    } else {
        _orientation = LoopMeAdOrientationLandscape;
    }
    
    self.measurePartners = [dictionary objectForKey:@"measure_partners"];
    
    BOOL autoLoading = YES;
    if ([dictionary objectForKey:@"autoloading"]) {
        autoLoading = [[dictionary objectForKey:@"autoloading"] boolValue];
    }
    [[NSUserDefaults standardUserDefaults] setBool:autoLoading forKey:LOOPME_USERDEFAULTS_KEY_AUTOLOADING];

}

- (void)parseXML:(NSData *)data error:(NSError **)error {
    self.wrapper = NO;
    LoopMeVASTXMLParser *parser = [[LoopMeVASTXMLParser alloc] initXMLWithData:data error:error];
    [parser initializeVastTrackingLinks:self.trackingLinks];
    [parser initializeVastAssetLinks:self.assetLinks error:error];
    
    self.adIDVAST = parser.adID;
    if (!self.adIDVAST) {
        self.adIDVAST = [NSString stringWithFormat:@"%u", arc4random_uniform(999999)];
    }
    self.vastFileContent = parser.vastFileContent;
    
    self.skipOffset = [parser skipOffset];
    self.duration = [parser duration];
    if ([parser isWrapper]) {
        NSString *adTagUriString = [parser adTagURL:error];
        _adTagURL = [NSURL URLWithString:adTagUriString];
        _wrapper = YES;
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Orientation: %@, expires in: %ld seconds", (self.orientation == LoopMeAdOrientationPortrait) ? @"portrait" : @"landscape", (long)self.expirationTime];
}

- (BOOL)useTracking:(NSString *)trakerName {
    return [self.measurePartners containsObject:trakerName];
}

- (BOOL)isAutoLoading {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"autoloading"];
}

@end
