//
//  LoopMeDestinationDisplayController.m
//  LoopMeSDK
//
//  Created by Dmitriy Lihachov on 8/21/12.
//  Copyright (c) 2012 LoopMe. All rights reserved.
//

#import <StoreKit/StoreKit.h>
#import <SafariServices/SafariServices.h>

#import "LoopMeBrowserViewController.h"
#import "LoopMeDestinationDisplayController.h"
#import "LoopMeProgressOverlayView.h"
#import "LoopMeErrorEventSender.h"
#import "LoopMeGlobalSettings.h"
#import <LoopMeUnitedSDK/LoopMeUnitedSDK-Swift.h>
#import "LoopMeDefinitions.h"

@interface LoopMeDestinationDisplayController ()
<
    LoopMeProgressOverlayViewDelegate,
    LoopMeBrowserControllerDelegate,
    SKStoreProductViewControllerDelegate,
    SFSafariViewControllerDelegate
>

@property (nonatomic, strong) LoopMeURLResolver *resolver;
@property (nonatomic, strong) LoopMeProgressOverlayView *overlayView;
@property (nonatomic, assign, getter = isLoadingDestination) BOOL loadingDestination;
@property (nonatomic, strong) SKStoreProductViewController *storeKitController;
@property (nonatomic, strong) SFSafariViewController *browserController;

@property (nonatomic, strong) NSURL *resorvingURL;

- (void)presentStoreKitControllerWithItemIdentifier:(NSString *)identifier
                                        fallbackURL:(NSURL *)URL;
- (void)hideOverlay;
- (void)dismissStoreKitController;

@end

@implementation LoopMeDestinationDisplayController

#pragma mark - Class Methods

+ (LoopMeDestinationDisplayController *)controllerWithDelegate:(id<LoopMeDestinationDisplayControllerDelegate>)delegate {
    LoopMeDestinationDisplayController *controller = [[LoopMeDestinationDisplayController alloc] init];
    controller.delegate = delegate;
    controller.resolver = [LoopMeURLResolver resolver];
    return controller;
}

#pragma mark - Private

- (void)hideOverlay {
    [LoopMeProgressOverlayView dismissOverlayFromWindow:[UIApplication sharedApplication].keyWindow
                                               animated:YES];
}

- (void)presentStoreKitControllerWithItemIdentifier:(NSString *)identifier fallbackURL:(NSURL *)URL {
    self.storeKitController = [[SKStoreProductViewController alloc] init];
    self.storeKitController.delegate = self;
    
    NSDictionary *parameters = @{SKStoreProductParameterITunesItemIdentifier: identifier};
    [self.storeKitController loadProductWithParameters:parameters completionBlock:nil];
    [self hideOverlay];
    
    if (self.browserController.presentingViewController) {
        [self.browserController presentViewController:self.storeKitController
                                             animated:YES
                                           completion:nil];
    } else {
        [[self.delegate viewControllerForPresentingModalView] presentViewController:self.storeKitController
                                                                           animated:YES
                                                                         completion:nil];
    }
}

- (void)dismissStoreKitController {
    [self.storeKitController.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [self.delegate destinationDisplayControllerDidDismissModal:self];
                UIViewController *presenting = [self.delegate viewControllerForPresentingModalView].presentingViewController;
                [presenting dismissViewControllerAnimated:NO completion:^{
                    [presenting presentViewController:[self.delegate viewControllerForPresentingModalView] animated:NO completion:nil];
                }];
    }];
}

#pragma mark - Public

- (void)displayDestinationWithURL:(NSURL *)URL {
    if (self.isLoadingDestination || ![self.delegate viewControllerForPresentingModalView]) {
        return;
    }
    
    self.loadingDestination = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate destinationDisplayControllerWillPresentModal:self];
        [LoopMeProgressOverlayView presentOverlayInWindow:[UIApplication sharedApplication].keyWindow animated:YES delegate:self];
        self.resorvingURL = URL;
        [self.resolver startResolvingWithURL:URL delegate:self];
    });
}

- (void)cancel {
    if (self.isLoadingDestination) {
        self.loadingDestination = NO;
        [self.resolver cancel];
        [self hideOverlay];
        [self.delegate destinationDisplayControllerDidDismissModal:self];
    }
}

#pragma mark - LoopMeURLResolverDelegate

- (void)showWebViewWithHTMLString:(NSString *)HTMLString
                          baseURL:(NSURL *)URL {
    [self hideOverlay];
    
    self.browserController = [[SFSafariViewController alloc] initWithURL:URL];
    self.browserController.delegate = self;
    self.browserController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    self.browserController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [[self.delegate viewControllerForPresentingModalView] presentViewController:self.browserController
                                                                       animated:YES
                                                                     completion:nil];
}

- (void)showStoreKitProductWithParameter:(NSString *)parameter fallbackURL:(NSURL *)URL {
    if (!!NSClassFromString(@"SKStoreProductViewController")) {
        [self presentStoreKitControllerWithItemIdentifier:parameter fallbackURL:URL];
    } else {
        [self openURLInApplication:URL];
    }
}

- (void)openURLInApplication:(NSURL *)URL {
    [self hideOverlay];
    [self.delegate destinationDisplayControllerWillLeaveApplication:self];

    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        [application openURL:URL options:@{}
           completionHandler:nil];
    } else {
        [application openURL:URL options:@{} completionHandler:nil];
    }
    self.loadingDestination = NO;
}

- (void)failedToResolveURLWithError:(NSError *)error {
    self.loadingDestination = NO;
    [self hideOverlay];
    NSMutableDictionary *infoDictionary = [self.delegate.adConfigurationObject toDictionary];
    [infoDictionary setObject:@"LoopMeVPAIDAdDispalyController" forKey: kErrorInfoClass];
    [infoDictionary setObject:self.resorvingURL.absoluteString forKey: kErrorInfoUrl];

    [LoopMeErrorEventSender sendError: LoopMeEventErrorTypeCustom
                         errorMessage: [NSString stringWithFormat: @"Wrong redirect: %@", self.resorvingURL.absoluteString]
                                 info: infoDictionary];
    [self.delegate destinationDisplayControllerDidDismissModal:self];
}


#pragma mark - LoopMeStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    self.loadingDestination = NO;
    [self dismissStoreKitController];
}

#pragma mark - <SFSafariViewControllerDelegate>

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    self.loadingDestination = NO;
    [self.delegate destinationDisplayControllerDidDismissModal:self];
}

#pragma mark - LoopMeBrowserControllerDelegate

- (void)dismissBrowserController:(LoopMeBrowserViewController *)browserController animated:(BOOL)animated {
    self.loadingDestination = NO;
    [[self.delegate viewControllerForPresentingModalView] dismissViewControllerAnimated:NO completion:^{
        [self.delegate destinationDisplayControllerDidDismissModal:self];
    }];
}

#pragma mark - LoopMeProgressOverlayViewDelegate

- (void)overlayCancelButtonPressed:(LoopMeProgressOverlayView *)overlay {
    [self cancel];
}

@end
