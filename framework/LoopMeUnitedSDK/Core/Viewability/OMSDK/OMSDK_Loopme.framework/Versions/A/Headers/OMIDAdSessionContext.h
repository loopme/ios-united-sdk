//
// Created by Daria Sukhonosova on 19/04/16.
//

#import <UIKit/UIKit.h>
#import "OMIDPartner.h"
#import "OMIDVerificationScriptResource.h"

/**
 *  Provides the ad session with details of the partner and whether to an HTML,
 *  JavaScript, or native session.
 */
@interface OMIDLoopmeAdSessionContext : NSObject

- (null_unspecified instancetype)init NS_UNAVAILABLE;

/**
 * DEPRECATED. Initializes a new ad session context providing reference to partner and
 * webview where OM SDK JavaScript service has been injected.
 *
 * Calling this method will set the ad session type to `html`.
 * <p>
 * NOTE: any attempt to create a new ad session will fail if OMID has not been activated
 *   (see {@link OMIDSDK} class for more information).
 *
 * @param partner Details of the integration partner responsible for the ad session.
 * @param webView The webView responsible for serving the ad content. Must be a UIWebView
 *   or WKWebView instance. The receiver holds a weak reference only.
 * @return A new HTML context instance. Returns nil if OMID has not been activated or if
 *   any of the parameters are nil.
 * @see OMIDSDK
 *
 * Warning:
 *  * This method will stop accepting a UIWebView on OM SDK 1.3.4 release or later.
 *  * This method will be fully removed in OM SDK 1.3.4 or later.  Use
 *   `-[OMIDAdSessionContext initWithPartner:webView:contentUrl:customReferenceIdentifier:error:]`
 *   instead.
 */
- (nullable instancetype)initWithPartner:(nonnull OMIDLoopmePartner *)partner
                                 webView:(nonnull UIView *)webView
               customReferenceIdentifier:(nullable NSString *)customReferenceIdentifier
                                   error:(NSError *_Nullable *_Nullable)error
    __deprecated_msg("Use -[OMIDAdSessionContext "
                     "initWithPartner:webView:contentUrl:customReferenceIdentifier:error:]");

/**
 * Initializes a new ad session context providing reference to partner and web view where
 * the OM SDK JavaScript service has been injected.
 *
 * Calling this method will set the ad session type to `html`.
 * <p>
 * NOTE: any attempt to create a new ad session will fail if OM SDK has not been
 * activated (see {@link OMIDSDK} class for more information).
 *
 * @param partner Details of the integration partner responsible for the ad session.
 * @param webView The webView responsible for serving the ad content. Must be a UIWebView
 *   or WKWebView instance. The receiver holds a weak reference only.
 * @param contentUrl contains the universal link to the ad's screen.
 * @return A new HTML context instance. Returns nil if OM SDK has not been activated or if
 *   any of the parameters are nil.
 * @see OMIDSDK
 *
 * Warning:
 *  * This method will stop accepting a UIWebView on OM SDK 1.3.4 release or later.
 */
- (nullable instancetype)initWithPartner:(nonnull OMIDLoopmePartner *)partner
                                 webView:(nonnull UIView *)webView
                              contentUrl:(nullable NSString *)contentUrl
               customReferenceIdentifier:(nullable NSString *)customReferenceIdentifier
                                   error:(NSError *_Nullable *_Nullable)error;

/**
 * DEPRECATED. Initializes a new ad session context providing reference to partner and a
 * list of script resources which should be managed by OMID.
 *
 * Calling this method will set the ad session type to `native`.
 * <p>
 * NOTE: any attempt to create a new ad session will fail if OM SDK has not been
 * activated (see {@link OMIDSDK} class for more information).
 *
 * @param partner Details of the integration partner responsible for the ad session.
 * @param resources The array of all verification providers who expect to receive OMID
 *   event data. Must contain at least one verification script. The receiver creates a
 *   deep copy of the array.
 * @return A new native context instance. Returns nil if OM SDK has not been activated or
 *   if any of the parameters are invalid.
 * @see OMIDSDK
 *
 * Warning:
 *  * This method will be fully removed in OM SDK 1.3.4 or later. Use
 *    `-[OMIDAdSessionContext
 * initWithPartner:script:resources:contentUrl:customReferenceIdentifier:error:]` instead.
 */
- (nullable instancetype)initWithPartner:(nonnull OMIDLoopmePartner *)partner
                                  script:(nonnull NSString *)script
                               resources:
                                   (nonnull NSArray<OMIDLoopmeVerificationScriptResource *> *)resources
               customReferenceIdentifier:(nullable NSString *)customReferenceIdentifier
                                   error:(NSError *_Nullable *_Nullable)error
    __deprecated_msg(
        "Use -[OMIDAdSessionContext "
        "initWithPartner:script:resources:contentUrl:customReferenceIdentifier:error:]");

/**
 * Initializes a new ad session context providing reference to partner and a list of
 * script resources which should be managed by OMID.
 *
 * Calling this method will set the ad session type to `native`.
 * <p>
 * NOTE: any attempt to create a new ad session will fail if OMID has not been activated
 * (see {@link OMIDSDK} class for more information).
 *
 * @param partner Details of the integration partner responsible for the ad session.
 * @param resources The array of all verification providers who expect to receive OMID
 *   event data. Must contain at least one verification script. The receiver creates a
 *   deep copy of the array.
 * @param contentUrl contains the universal link to the ad's screen.
 * @return A new native context instance. Returns nil if OMID has not been activated or if any of the parameters are invalid.
 * @see OMIDSDK
 */
- (nullable instancetype)initWithPartner:(nonnull OMIDLoopmePartner *)partner
                                  script:(nonnull NSString *)script
                               resources:(nonnull NSArray<OMIDLoopmeVerificationScriptResource *> *)resources
                              contentUrl:(nullable NSString *)contentUrl
               customReferenceIdentifier:(nullable NSString *)customReferenceIdentifier
                                   error:(NSError *_Nullable *_Nullable)error;

/**
 * Initializes a new ad session context providing reference to partner and web view where
 * OM SDK JavaScript service has been injected.
 *
 * Calling this method will set the ad session type to `javascript`.
 * <p>
 * NOTE: any attempt to create a new ad session will fail if OMID has not been activated
 * (see {@link OMIDSDK} class for more information).
 *
 * @param partner Details of the integration partner responsible for the ad session.
 * @param webView The webView responsible for serving the ad content. Must be a UIWebView
 *   or WKWebView instance. The receiver holds a weak reference only.
 * @param contentUrl contains the universal link to the ad's screen.
 * @return A new JavaScript context instance. Returns nil if OM SDK has not been
 *   activated or if any of the parameters are invalid.
 * @see OMIDSDK
 *
 * Warning:
 *  * This method will stop accepting a UIWebView on OM SDK 1.3.4 release or later.
 */
- (nullable instancetype)initWithPartner:(nonnull OMIDLoopmePartner *)partner
                       javaScriptWebView:(nonnull UIView *)webView
                              contentUrl:(nullable NSString *)contentUrl
               customReferenceIdentifier:(nullable NSString *)customReferenceIdentifier
                                   error:(NSError *_Nullable *_Nullable)error;

@end
