//
// Created by Daria Sukhonosova on 11/05/16.
// Copyright (c) 2016 Integral. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoopMe_AbstractAvidAdSession.h"

@interface LoopMe_AbstractAvidManagedAdSession : LoopMe_AbstractAvidAdSession

- (void)injectJavaScriptResource:(NSString *)javaScriptResource;

@end
