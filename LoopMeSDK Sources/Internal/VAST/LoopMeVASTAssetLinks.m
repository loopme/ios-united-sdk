//
//  LoopMeVASTAssetLinks.m
//  LoopMeSDK
//
//  Copyright © 2016 LoopMe. All rights reserved.
//

#import "LoopMeVASTAssetLinks.h"

@implementation LoopMeVASTAssetLinks

- (NSDictionary *)adParameters {
    if (_adParameters) {
        return _adParameters;
    } else {
        return @{};
    }
}

@end
