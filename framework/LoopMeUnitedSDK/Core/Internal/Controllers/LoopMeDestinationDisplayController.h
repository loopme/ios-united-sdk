//
//  LoopMeDestinationDisplayController.h
//  LoopMeSDK
//
//  Created by Dmitriy Lihachov on 8/21/12.
//  Copyright (c) 2013 LoopMe. All rights reserved.
//

#import "LoopMeURLResolver.h"

@class LoopMeBrowserViewController;

@protocol LoopMeDestinationDisplayControllerDelegate;

@interface LoopMeDestinationDisplayController : NSObject
<
    LoopMeURLResolverDelegate
>

@property (nonatomic, weak) id<LoopMeDestinationDisplayControllerDelegate> delegate;

+ (LoopMeDestinationDisplayController *)controllerWithDelegate:(id<LoopMeDestinationDisplayControllerDelegate>)delegate;
- (void)displayDestinationWithURL:(NSURL *)URL;
- (void)cancel;

@end

@protocol LoopMeDestinationDisplayControllerDelegate <NSObject>

- (UIViewController *)viewControllerForPresentingModalView;

- (void)destinationDisplayControllerWillPresentModal:(LoopMeDestinationDisplayController *)destinationDisplayController;
- (void)destinationDisplayControllerWillLeaveApplication:(LoopMeDestinationDisplayController *)destinationDisplayController;
- (void)destinationDisplayControllerDidDismissModal:(LoopMeDestinationDisplayController *)destinationDisplayController;
- (NSString *)appKey;

@end
