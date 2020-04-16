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

@protocol LoopMeVpaidProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface LoopMeVpaidScriptMessageHandler : NSObject <WKScriptMessageHandler>

@property (nonatomic, weak) id<LoopMeVpaidProtocol> vpaidCommandProcessor;

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
