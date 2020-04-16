//
//  OMIDSDK.h
//  AppVerificationLibrary
//
//  Created by Daria on 05/06/2017.
//

#import <Foundation/Foundation.h>

/// API Note: this value must be copied into the ad SDK's binary. It cannot be an extern defined in
/// the OMID library.
#define OMIDSDKAPIVersionString @"{\"v\":\"1.3.3\",\"a\":\"1\"}"

/**
 *  This application level class will be called by all integration partners to ensure OM SDK has been activated before calling any other API methods.
 * Any attempt to use other API methods prior to activation will result in an error.
 *
 * Note that OM SDK may only be used on the main UI thread.
 * Make sure you are on the main thread when you initialize the SDK, create its
 * objects, and invoke its methods.
 */
@interface OMIDLoopmeSDK : NSObject

/**
 *  The current semantic version of the integrated OMID library.
 */
+ (nonnull NSString *)versionString;

/**
 *  Shared OMIDSDK instance.
 */
@property(class, readonly, nonnull) OMIDLoopmeSDK *sharedInstance
NS_SWIFT_NAME(shared);

/**
 *  A Boolean value indicating whether the OMID library has been activated.
 *
 *  The value of this property is YES if the OMID library has already been activated. Allows the integration partner to check that they are compatible with the running OMID library version.
 */
@property(atomic, readonly, getter = isActive) BOOL active;

/**
 *  Enables the integration partner to activate OMID.
 */
- (BOOL)activate;

#pragma mark - Deprecated Methods

/**
 * DEPRECATED. Allows the integration partner to check that they are compatible with the
 * running OM SDK library version.
 *
 * @param OMIDAPIVersion The version of OM SDK library integrated by the partner.
 * @return YES if the version supplied is compatible with the integrated OM SDK library
 *   version.
 *
 * Warning:
 *  * This method will be fully removed in OM SDK 1.3.4 or later.
 */
+ (BOOL)isCompatibleWithOMIDAPIVersion:(nonnull NSString *)OMIDAPIVersion
    NS_SWIFT_NAME(isCompatible(withOMIDAPIVersion:))
        __deprecated_msg("Checking the version number is no longer needed");

/**
 * DEPRECATED. Enables the integration partner to activate OM SDK prior to calling any
 * other API methods.
 *
 * @param OMIDAPIVersion The version of OM SDK library integrated by the partner.
 * @param error If an error occurs, contains an NSError object that describes the problem.
 * @return YES if activation was successful when checking the supplied version number for
 *   compatibility.
 *
 * Warning:
 *  * This method will be fully removed in OM SDK 1.3.4 or later.  Use
 *   `-[OMIDSDK activate]` instead.
 */
- (BOOL)activateWithOMIDAPIVersion:(nonnull NSString *)OMIDAPIVersion
                             error:(NSError *_Nullable *_Nullable)error
    __deprecated_msg("Use -[OMIDSDK activate]");

@end

