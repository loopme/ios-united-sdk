//
//  MRAIDWKUserContentController.m
//  LoopMeUnitedSDK
//
//  Created by Bohdan on 02.04.2020.
//  Copyright © 2020 LoopMe. All rights reserved.
//

#import "LoopMeMRAIDScriptMessageHandler.h"

@implementation LoopMeMRAIDScriptMessageHandler

#pragma mark - WKScriptMessageHandler

- (instancetype)init {
    self = [super init];
    return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([[message name] isEqualToString:@"mraid"]) {
        NSLog(@"MRAID: %@", [message body]);
        [self.mraidClient processCommand:[[message body] objectForKey:@"command"] withParams:[[message body] objectForKey:@"params"]];
    }
}

@end
