//
//  MRAIDWKUserContentController.h
//  LoopMeUnitedSDK
//
//  Created by Bohdan on 02.04.2020.
//  Copyright © 2020 LoopMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import "LoopMeMRAIDClient.h"

NS_ASSUME_NONNULL_BEGIN

@interface LoopMeMRAIDScriptMessageHandler : NSObject <WKScriptMessageHandler>

@property (nonatomic, weak) LoopMeMRAIDClient *mraidClient;

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
