//
//  LoopMeVastXMLParser.m
//  LoopMeSDK
//
//  Copyright © 2016 LoopMe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoopMeVASTXMLParser.h"
#import "LoopMeVASTProgressEvent.h"
#import "LoopMeVPAIDConverter.h"
#import "LoopMeVPAIDError.h"
#import "DDXML.h"

@interface LoopMeVASTXMLParser ()

@property (nonatomic) DDXMLDocument *xmlDoc;
@property (nonatomic) DDXMLNode *linearCreativeNode;
@property (nonatomic) DDXMLNode *companionCreativeNode;
@property (nonatomic) NSString *adID;
@property (nonatomic, readwrite) LoopMeSkipOffset skipOffset;
@property (nonatomic, assign) CMTime duration;
@property (nonatomic, readwrite) BOOL wrapper;

- (void)initCreativesNodeWithError:(NSError **)error;
- (NSArray *)errorLinkTemplates;
- (NSArray *)impressionLinks;
- (LoopMeVastLinearTrackingLinks *)linearTrackLinks;

- (LoopMeVastCompanionAdsTrackingLinks *)companionAdsTrackLinks;

- (NSString *)trim:(NSString *)string;

- (NSString *)adjustName:(NSString *)name;
@end

@implementation LoopMeVASTXMLParser

- (instancetype)initXMLWithData:(NSData *)data error:(NSError **)error {
    if (self = [super init]) {
        self.xmlDoc = [[DDXMLDocument alloc] initWithData:data options:DDXMLDocumentXMLKind error:error];
        
        //KissXML can't work with namespaces
        DDXMLNode * _Nullable element = [self.xmlDoc rootElement];
        while (element != nil) {
            if ([element isKindOfClass:[DDXMLElement class]]) {
                [(DDXMLElement *)element removeNamespaceForPrefix:@""];
            }
            element = [element nextNode];
        }
        //-----------------------------------------
    
        if (error && *error) {
            *error = [LoopMeVPAIDError errorForStatusCode:LoopMeVPAIDErrorCodeXMLParsingFailed];
            return nil;
        }
        if ([self isNoAds]) {
            if (error) *error = [LoopMeVPAIDError errorForStatusCode:204];
            return nil;
        }
        [self initCreativesNodeWithError:error];
    }
    
    return self;
}

#pragma mark - public

- (NSString *)vastFileContent {
    return [self.xmlDoc XMLString];
}

- (void)initializeVastTrackingLinks:(LoopMeVASTTrackingLinks *)vastLinks {
    [vastLinks.errorLinkTemplates addObjectsFromArray:[self errorLinkTemplates]];
    [vastLinks.impressionLinks addObjectsFromArray:[self impressionLinks]];
    [vastLinks.linearTrackingLinks add:[self linearTrackLinks]];
    [vastLinks.companionTrackingLinks add:[self companionAdsTrackLinks]];
    [vastLinks.viewableImpression add:[self viewableImpression]];
    vastLinks.clickThroughVideo = [self videoClickThrough];
    vastLinks.clickThroughCompanion = [self companionClickThrough];
}

- (void)initializeVastAssetLinks:(LoopMeVASTAssetLinks *)vastAssets error:(NSError **)error {
    [self initMediaFiles:vastAssets];
    [self initInteractiveFiles:vastAssets];
    
    if (![self assetsExist:vastAssets] && error) {
        *error = [LoopMeVPAIDError errorForStatusCode:LoopMeVPAIDErrorCodeMediaNotSupport];
    }
    
    [self initStaticResources:vastAssets];
    [self initAdParameters:vastAssets];
    [self initAdVerifications:vastAssets];
}

- (NSString *)adTagURL:(NSError **)error {
    NSArray *uris = [self.xmlDoc nodesForXPath:@"//VAST/Ad/Wrapper/VASTAdTagURI" error:error];
    if (error && !*error) {
        if (uris && uris.count > 0) {
            NSString *uri = [uris[0] stringValue];
            uri = [self removeEncodeBadSymbols:uri];
            return [self trim:uri];
        }
    } else {
        if (error) *error = [LoopMeVPAIDError errorForStatusCode:LoopMeVPAIDErrorCodeXMLParsingFailed];
    }
    return nil;
}

#pragma mark - private

- (BOOL)assetsExist:(LoopMeVASTAssetLinks *)vastAssets  {
    BOOL exist = !!vastAssets.vpaidURL.length;
    if (exist) return true;
    
    for (NSString *URL in vastAssets.videoURL) {
        exist = !!URL.length;
        if (exist) return true;
    }
    return false;
}

- (NSArray *)sortMediaFiles:(NSArray *)mediaFiles {
    mediaFiles = [mediaFiles sortedArrayUsingComparator:^NSComparisonResult(DDXMLElement *obj1, DDXMLElement *obj2) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        if (screenSize.height > screenSize.width) {
            screenSize = CGSizeMake(screenSize.height, screenSize.width);
        }
        int width1 = [[[obj1 attributeForName:@"width"] stringValue] intValue];
        int height1 = [[[obj1 attributeForName:@"height"] stringValue] intValue];
        
        int width2 = [[[obj2 attributeForName:@"width"] stringValue] intValue];
        int height2 = [[[obj2 attributeForName:@"height"] stringValue] intValue];
        
        int delta1 = fabs(screenSize.width - width1) + fabs(screenSize.height - height1);
        int delta2 = fabs(screenSize.width - width2) + fabs(screenSize.height - height2);
        
        return delta1 > delta2;
    }];
    return mediaFiles;
}

- (void)initMediaFiles:(LoopMeVASTAssetLinks *)vastAssets {
    NSArray *mediaFiles = [self.linearCreativeNode nodesForXPath:@"Linear/MediaFiles/MediaFile" error:nil];
    mediaFiles = [self sortMediaFiles:mediaFiles];
    NSMutableArray *videoURLs = [[NSMutableArray alloc] init];
    for (DDXMLElement *element in mediaFiles) {
        NSString *delivery = [[element attributeForName:@"delivery"] stringValue];
        NSString *framework = [[element attributeForName:@"apiFramework"] stringValue];
        NSString *type = [[element attributeForName:@"type"] stringValue];
        
        if ([delivery isEqualToString:@"progressive"] && [type isEqualToString:@"video/mp4"]) {
            [videoURLs addObject:[self trim:[element stringValue]]];
        } else if([framework isEqualToString:@"VPAID"] && [type isEqualToString:@"application/javascript"]) {
            vastAssets.vpaidURL = [self trim:[element stringValue]];
        }
    }
    vastAssets.videoURL = videoURLs;
}

- (void)initInteractiveFiles:(LoopMeVASTAssetLinks *)vastAssets {
    NSArray *interactiveCreativeFiles = [self.linearCreativeNode nodesForXPath:@"Linear/MediaFiles/InteractiveCreativeFile" error:nil];
    for (DDXMLElement *element in interactiveCreativeFiles) {
        NSString *framework = [[element attributeForName:@"apiFramework"] stringValue];
        NSString *type = [[element attributeForName:@"type"] stringValue];
        
        if([framework isEqualToString:@"VPAID"] && [type isEqualToString:@"application/javascript"]) {
            vastAssets.vpaidURL = [self trim:[element stringValue]];
        }
    }
}

- (void)initAdParameters:(LoopMeVASTAssetLinks *)vastAssets {
    NSArray *adParameters = [self.linearCreativeNode nodesForXPath:@"Linear/AdParameters" error:nil];
    if (adParameters && adParameters.count > 0) {
        NSString *adParametersString = [adParameters[0] stringValue];
        adParametersString = [adParametersString stringByReplacingOccurrencesOfString:@"\\s" withString:@""
                                                                              options:NSRegularExpressionSearch
                                                                                range:NSMakeRange(0, [adParametersString length])];
        vastAssets.adParameters = @{@"AdParameters":adParametersString};
    }
}

- (void)initStaticResources:(LoopMeVASTAssetLinks *)vastAssets {
    NSArray *staticResources = [self.companionCreativeNode nodesForXPath:@"CompanionAds/Companion/StaticResource" error:nil];
    staticResources = [self sortMediaFiles:staticResources];

    NSMutableArray *staticResourcesURLs = [[NSMutableArray alloc] init];
    for (DDXMLElement *element in staticResources) {
        [staticResourcesURLs addObject:[self trim:[element stringValue]]];
    }
    if (vastAssets.endCard) {
        [vastAssets.endCard addObjectsFromArray:staticResourcesURLs];
    } else {
        vastAssets.endCard = staticResourcesURLs;
    }
}

- (void)initAdVerifications:(LoopMeVASTAssetLinks *)vastAssets {
    NSArray *jsresources = [self.xmlDoc nodesForXPath:@"//VAST/Ad/InLine/AdVerifications/Verification/JavaScriptResource" error:nil];
    
    NSMutableArray *links = [[NSMutableArray alloc] init];
    for (DDXMLElement *element in jsresources) {
        [links addObject:[element stringValue]];
    }
    vastAssets.adVerification = links;
}

- (BOOL)isWrapper {
    return [self.xmlDoc nodesForXPath:@"//VAST/Ad/Wrapper" error:nil].count != 0;
}

- (BOOL)isNoAds {
    NSArray *status = [self.xmlDoc nodesForXPath:@"//VAST/status" error:nil];
    return status.count > 0 && [[status[0] stringValue] isEqualToString:@"NO_AD"];
}

- (void)initCreativesNodeWithError:(NSError **)error {
    NSArray *creatives = nil;
    if (self.isWrapper) {
        creatives = [self.xmlDoc nodesForXPath:@"//VAST/Ad/Wrapper/Creatives/Creative" error:error];
    } else {
        creatives = [self.xmlDoc nodesForXPath:@"//VAST/Ad/InLine/Creatives/Creative" error:error];
    }
    if (error && !*error) {
        for (DDXMLNode *creativeNode in creatives) {
            if (!self.adID.length) {
                self.adID = [[(DDXMLElement *)creativeNode attributeForName:@"id"] stringValue];
            }
        
            if ([creativeNode nodesForXPath:@"Linear" error:nil].count > 0) {
                self.linearCreativeNode = creativeNode;
            } else if ([creativeNode nodesForXPath:@"CompanionAds" error:nil].count > 0) {
                self.companionCreativeNode = creativeNode;
            }
        }
    } else {
        if (error) *error = [LoopMeVPAIDError errorForStatusCode:LoopMeVPAIDErrorCodeXMLParsingFailed];
    }
}

- (LoopMeSkipOffset)skipOffset {
    if (_skipOffset.value != 0) {
        return _skipOffset;
    }
    NSString *timeString = [[(DDXMLElement *)[[self.linearCreativeNode nodesForXPath:@"Linear" error:nil] objectAtIndex:0] attributeForName:@"skipoffset"] stringValue];
    _skipOffset = [LoopMeVPAIDConverter skipOffsetFromString:timeString];
    return _skipOffset;
}

- (CMTime)duration {
    if (_duration.value != 0) {
        return _duration;
    }
    
    NSString *durationString = [[[self.linearCreativeNode nodesForXPath:@"Linear/Duration" error:nil] firstObject] stringValue];
    _duration = [LoopMeVPAIDConverter timeFromString:durationString];
    return _duration;
}

//tracking links
- (NSString *)videoClickThrough {
    NSArray *videoClickThrough = [self.linearCreativeNode nodesForXPath:@"Linear/VideoClicks/ClickThrough" error:nil];
    if (videoClickThrough.count == 0) {
        return nil;
    }
    DDXMLNode *node = videoClickThrough[0];
    return [self trim:[node stringValue]];
}

- (NSString *)companionClickThrough {
    NSArray *companionClickThrough = [self.linearCreativeNode nodesForXPath:@"//Companion/CompanionClickThrough" error:nil];
    if (companionClickThrough.count == 0) {
        return nil;
    }
    DDXMLNode *node = companionClickThrough[0];
    return [self trim:[node stringValue]];
}

- (NSArray *)errorLinkTemplates {
    NSMutableArray *errorLinkTemplates = [[NSMutableArray alloc] init];
    NSArray *errors = nil;
    if (self.isWrapper) {
        errors = [self.xmlDoc nodesForXPath:@"//VAST/Ad/Wrapper/Error" error:nil];
    } else {
        errors = [self.xmlDoc nodesForXPath:@"//VAST/Ad/InLine/Error" error:nil];
    }
    for (DDXMLNode *node in errors) {
        [errorLinkTemplates addObject:[self trim:[node stringValue]]];
    }
    return errorLinkTemplates;
}

- (NSArray *)impressionLinks {
    NSMutableArray *impressionLinks = [[NSMutableArray alloc] init];
    NSArray *impressions = nil;
    if (self.isWrapper) {
        impressions = [self.xmlDoc nodesForXPath:@"//VAST/Ad/Wrapper/Impression" error:nil];
    } else {
        impressions = [self.xmlDoc nodesForXPath:@"//VAST/Ad/InLine/Impression" error:nil];
    }
    for (DDXMLNode *node in impressions) {
        [impressionLinks addObject:[self trim:[node stringValue]]];
    }
    return impressionLinks;
}

- (LoopMeVastLinearTrackingLinks *)linearTrackLinks {
    LoopMeVastLinearTrackingLinks *linearTrackLinks = [[LoopMeVastLinearTrackingLinks alloc] init];
    
    NSArray *trackingEvents = [self.linearCreativeNode nodesForXPath:@"Linear/TrackingEvents/Tracking" error:nil];

    for (DDXMLElement *tracking in trackingEvents) {
        NSString *attributeName = [[tracking attributeForName:@"event"] stringValue];
        attributeName = [self adjustName:attributeName];
        if ([linearTrackLinks respondsToSelector:NSSelectorFromString(attributeName)]) {
            NSMutableArray *attArray = [linearTrackLinks performSelector:NSSelectorFromString(attributeName)];

            NSString *trackingEvent = [self trim:[tracking stringValue]];

            if ([attributeName isEqualToString:@"progress"]) {
                NSString *offset = [[tracking attributeForName:@"offset"] stringValue];
                LoopMeVASTProgressEvent *event = [LoopMeVASTProgressEvent eventWithOffset:offset link:trackingEvent];
                [attArray addObject:event];
            } else {
                [attArray addObject:trackingEvent];
            }
        }
    }

    NSArray *videoClickTracking = [self.linearCreativeNode nodesForXPath:@"Linear/VideoClicks/ClickTracking" error:nil];
    for (DDXMLNode *node in videoClickTracking) {
        [linearTrackLinks.clickTracking addObject:[self trim:[node stringValue]]];
    }
    
    return linearTrackLinks;
}

- (LoopMeVastCompanionAdsTrackingLinks *)companionAdsTrackLinks {
    LoopMeVastCompanionAdsTrackingLinks *companionTrackingLinks = [[LoopMeVastCompanionAdsTrackingLinks alloc] init];
    
    NSArray *companionAds = [self.companionCreativeNode nodesForXPath:@"CompanionAds/Companion" error:nil];
    for (DDXMLNode *ad in companionAds) {
        NSArray *trackingEvents = [ad nodesForXPath:@"TrackingEvents/Tracking" error:nil];
        
        for (DDXMLElement *tracking in trackingEvents) {
            NSString *attributeName = [[tracking attributeForName:@"event"] stringValue];
            if ([companionTrackingLinks respondsToSelector:NSSelectorFromString(attributeName)]) {
                NSMutableArray *attArray = [companionTrackingLinks performSelector:NSSelectorFromString(attributeName)];
                [attArray addObject:[self trim:[tracking stringValue]]];
            }
        }
        
        NSArray *videoClickTracking = [ad nodesForXPath:@"CompanionClickTracking" error:nil];
        for (DDXMLNode *node in videoClickTracking) {
            [companionTrackingLinks.clickTracking addObject:[self trim:[node stringValue]]];
        }
    }
    
    return companionTrackingLinks;
}

- (LoopMeVASTViewableImpression *)viewableImpression {
    LoopMeVASTViewableImpression *viewableImpressionLinks = [[LoopMeVASTViewableImpression alloc] init];
    
    //ViewableImpressions
    NSMutableArray *viewableLinks = [[NSMutableArray alloc] init];
    NSArray *viewableImpressions = nil;
    if (self.isWrapper) {
        viewableImpressions = [self.xmlDoc nodesForXPath:@"//VAST/Ad/Wrapper/ViewableImpression/Viewable" error:nil];
    } else {
        viewableImpressions = [self.xmlDoc nodesForXPath:@"//VAST/Ad/InLine/ViewableImpression/Viewable" error:nil];
    }
    for (DDXMLNode *node in viewableImpressions) {
        [viewableLinks addObject:[self trim:[node stringValue]]];
    }
    [viewableImpressionLinks.viewable addObjectsFromArray:viewableLinks];
    
    //NotViewable
    NSMutableArray *notViewableLinks = [[NSMutableArray alloc] init];
    NSArray *notViewable = nil;
    if (self.isWrapper) {
        notViewable = [self.xmlDoc nodesForXPath:@"//VAST/Ad/Wrapper/ViewableImpression/NotViewable" error:nil];
    } else {
        notViewable = [self.xmlDoc nodesForXPath:@"//VAST/Ad/InLine/ViewableImpression/NotViewable" error:nil];
    }
    for (DDXMLNode *node in notViewable) {
        [notViewableLinks addObject:[self trim:[node stringValue]]];
    }
    [viewableImpressionLinks.notViewable addObjectsFromArray:notViewableLinks];
    
    //NotViewable
    NSMutableArray *viewUndeterminedLinks = [[NSMutableArray alloc] init];
    NSArray *viewUndetermined = nil;
    if (self.isWrapper) {
        viewUndetermined = [self.xmlDoc nodesForXPath:@"//VAST/Ad/Wrapper/ViewableImpression/ViewUndetermined" error:nil];
    } else {
        viewUndetermined = [self.xmlDoc nodesForXPath:@"//VAST/Ad/InLine/ViewableImpression/ViewUndetermined" error:nil];
    }
    for (DDXMLNode *node in viewUndetermined) {
        [viewUndeterminedLinks addObject:[self trim:[node stringValue]]];
    }
    [viewableImpressionLinks.viewUndetermined addObjectsFromArray:viewUndeterminedLinks];
    
    return viewableImpressionLinks;
}

- (NSString *)trim:(NSString *)string {
    return [string stringByTrimmingCharactersInSet:[NSMutableCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)removeEncodeBadSymbols:(NSString *)string {
    string = [string stringByReplacingOccurrencesOfString:@"{" withString:@"%7B"];
    string = [string stringByReplacingOccurrencesOfString:@"}" withString:@"%7D"];
    string = [string stringByReplacingOccurrencesOfString:@"%%" withString:@"%25%25"];
    return string;
}

- (NSString *)adjustName:(NSString *)name {
    if ([name isEqualToString:@"fullscreen"] || [name isEqualToString:@"playerExpand"]) {
        return @"expand";
    }
    if ([name isEqualToString:@"exitFullscreen"] || [name isEqualToString:@"playerCollapse"]) {
         return @"collapse";
    }
    if ([name isEqualToString:@"close"]) {
        return @"closeLinear";
    }
    return name;
}

@end
