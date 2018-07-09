//
//  LoopMeAdConfiguration.h
//  LoopMeSDK
//
//  Created by Dmitriy Lihachov on 07/11/13.
//  Copyright (c) 2013 LoopMe. All rights reserved.

#import <UIKit/UIKit.h>
#import "LoopMeVASTXMLParser.h"
#import "LoopMeVASTEventTracker.h"
#import "LoopMeSkipOffset.h"


typedef NS_ENUM (NSInteger, LoopMeAdOrientation) {
    LoopMeAdOrientationUndefined,
    LoopMeAdOrientationPortrait,
    LoopMeAdOrientationLandscape
};

typedef NS_ENUM (NSInteger, LoopMeCreativeType) {
    LoopMeCreativeTypeVPAID,
    LoopMeCreativeTypeVAST,
    LoopMeCreativeTypeNormal,
    LoopMeCreativeTypeMRAID
};

struct LoopMeMRAIDExpandProperties {
    int width;
    int height;
    BOOL useCustomClose;
};


extern const struct LoopMeTrackerNameStruct {
    __unsafe_unretained NSString *moat;
    __unsafe_unretained NSString *dv;
    __unsafe_unretained NSString *ias;
} LoopMeTrackerName;

@interface LoopMeAdConfiguration : NSObject

- (instancetype)initWithData:(NSData *)data error:(NSError **)error;
- (BOOL)useTracking:(NSString *)trakerName;
- (BOOL)isPortrait;
- (BOOL)isVPAID;
- (BOOL)isAutoLoading;
- (void)parseXML:(NSData *)data error:(NSError **)error;

@property (nonatomic, strong) NSString *appKey;
@property (nonatomic, assign) BOOL allowOrientationChange;
@property (nonatomic, assign) LoopMeAdOrientation orientation;
@property (nonatomic, assign) struct LoopMeMRAIDExpandProperties expandProperties;
@property (nonatomic, assign) LoopMeCreativeType creativeType;
@property (nonatomic, strong) NSDictionary *adIdsForMOAT;
@property (nonatomic, strong) NSDictionary *adIdsForIAS;
@property (nonatomic, assign) NSInteger expirationTime;
@property (nonatomic, strong) NSString *creativeContent;

@property (nonatomic) LoopMeVASTAssetLinks *assetLinks;
@property (nonatomic) LoopMeVASTTrackingLinks *trackingLinks;
@property (nonatomic) LoopMeVASTEventTracker *eventTracker;
@property (nonatomic) LoopMeSkipOffset skipOffset;
@property (nonatomic) CMTime duration;

@property (nonatomic) NSString *adIDVAST;
@property (nonatomic) NSString *vastFileContent;

@property (nonatomic, getter=isWrapper) BOOL wrapper;
@property (nonatomic) NSURL *adTagURL;

@property (nonatomic, assign, getter = isPreload25Enabled) BOOL preload25;
@property (nonatomic, assign, getter = isV360) BOOL v360;

@end
