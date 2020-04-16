//
//  MRAIDWKUserContentController.m
//  LoopMeUnitedSDK
//
//  Created by Bohdan on 02.04.2020.
//  Copyright © 2020 LoopMe. All rights reserved.
//

#import "LoopMeVpaidScriptMessageHandler.h"
#import "LoopMeVPAIDClient.h"

@implementation LoopMeVpaidScriptMessageHandler

#pragma mark - WKScriptMessageHandler

- (instancetype)init {
    self = [super init];
    return self;
}

- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
    
    if ([[message name] isEqualToString:@"vpaid"]) {
        NSLog(@"VPAID: %@", [message body]);
        [self.vpaidCommandProcessor processCommand:[[message body] objectForKey:@"command"] withParams:[[message body] objectForKey:@"params"]];
    }
}

@end
