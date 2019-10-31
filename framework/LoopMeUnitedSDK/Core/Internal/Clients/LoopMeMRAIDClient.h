//
//  LoopMeMRAIDClient.h
//  LoopMeSDK
//
//  Created by Bohdan Korda on 10/24/16.
//  Copyright © 2016 LoopMe. All rights reserved.
//
#import <Foundation/Foundation.h>

@class LoopMeMRAIDClient;
@class WKWebView;

@protocol LoopMeMRAIDClientDelegate;

extern const struct LoopMeMRAIDFunctionsStruct {
    __unsafe_unretained NSString *ready;
    __unsafe_unretained NSString *error;
    __unsafe_unretained NSString *sizeChange;
    __unsafe_unretained NSString *stateChange;
    __unsafe_unretained NSString *viewableChange;
    __unsafe_unretained NSString *setScreenSize;
    __unsafe_unretained NSString *setPlacementType;
    __unsafe_unretained NSString *setSupports;
    __unsafe_unretained NSString *setCurrentPosition;
    __unsafe_unretained NSString *setDefaultPosition;
    __unsafe_unretained NSString *setMaxSize;
    __unsafe_unretained NSString *setExpandSize;
} LoopMeMRAIDFunctions;

extern const struct LoopMeMRAIDEventStruct {
    __unsafe_unretained NSString *open;
    __unsafe_unretained NSString *playVideo;
    __unsafe_unretained NSString *resize;
    __unsafe_unretained NSString *useCustomClose;
    __unsafe_unretained NSString *setOrientationProperties;
    __unsafe_unretained NSString *setResizeProperties;
    __unsafe_unretained NSString *storePicture;
    __unsafe_unretained NSString *createCalendarEvent;
    __unsafe_unretained NSString *close;
    __unsafe_unretained NSString *expand;
} LoopMeMRAIDEvent;

extern const struct LoopMeMRAIDStateStruct {
    __unsafe_unretained NSString *loading;
    __unsafe_unretained NSString *defaultt;
    __unsafe_unretained NSString *expanded;
    __unsafe_unretained NSString *resized;
    __unsafe_unretained NSString *hidden;
} LoopMeMRAIDState;

@interface LoopMeMRAIDClient : NSObject

@property (nonatomic) NSDictionary *expandProperties;
@property (nonatomic) NSDictionary *resizeProperties;
@property (nonatomic) NSString *state;

- (instancetype)initWithDelegate:(id<LoopMeMRAIDClientDelegate>)deleagate;
- (BOOL)shouldInterceptURL:(NSURL *)URL;
- (void)processCommand:(NSString *)command withParams:(NSDictionary *)params;
- (void)executeEvent:(NSString *)event params:(NSArray *)params;
- (void)setSupports;
//- (void)getOrientationProperties:(void (^)(NSDictionary *))completion;
//- (void)getExpandProperties:(void (^)(NSDictionary *))completion;
//- (void)getResizeProperties:(void (^)(NSDictionary *))completion;
//- (void)getState:(void (^)(NSString *))completion;

@end

@protocol LoopMeMRAIDClientDelegate <NSObject>

- (WKWebView *)webViewTransport;
- (void)mraidClient:(LoopMeMRAIDClient *)client shouldOpenURL:(NSURL *)URL;
- (void)mraidClientDidReceiveCloseCommand:(LoopMeMRAIDClient *)client;
- (void)mraidClientDidReceiveExpandCommand:(LoopMeMRAIDClient *)client;
- (void)mraidClient:(LoopMeMRAIDClient *)client useCustomClose:(BOOL)useCustomCLose;
- (void)mraidClient:(LoopMeMRAIDClient *)client sholdPlayVideo:(NSURL *)URL;
- (void)mraidClient:(LoopMeMRAIDClient *)client setOrientationProperties:(NSDictionary *)orientationProperties;
- (void)mraidClientDidResizeAd:(LoopMeMRAIDClient *)client;

@end
