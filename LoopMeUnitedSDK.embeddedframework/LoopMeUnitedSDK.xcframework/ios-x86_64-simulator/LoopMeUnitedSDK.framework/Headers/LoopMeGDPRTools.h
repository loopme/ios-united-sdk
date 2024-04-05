//
//  LoopMeGDPRTools.h
//  LoopMeSDK
//
//  Created by Bohdan on 4/12/18.
//  Copyright © 2018 LoopMe. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LoopMeConsentType) {
    LoopMeConsentTypeDidNotSet = -1,
    LoopMeConsentTypeLoopMe = 0,
    LoopMeConsentTypePublisher = 1,
    LoopMeConsentTypeUserRestricted = 2,
    LoopMeConsentTypeFailedAPI = 3
};

/**
 * The `LoopMeGDPRTools` class provides facilities for managing user consent.
 * Read more https://www.eugdpr.org/
 *
 * LoopMe SDK supports 3 cases of managing consents:
 * 1. If your application already has the Consent Management Platform (CMP) implemented, LoopMe SDK will automatically get consent string from the default storage.
 *
 * 2. You have no CMP implemented, LoopMe SDK shows GDPR consent pop-up to ask user for the consent for the first time.
 * 3. You manage users consent with your custom solution different from GDPR Consent Framework, then you can pass user consent by setting true or false value.
 */
@interface LoopMeGDPRTools : NSObject

+ (instancetype _Nonnull )sharedInstance;

/**
 * Indicates if user agree or does not in LoopMe GDPR window or was set by publisher.
 * Check this value after LoopMe GDPR window was shown.
 */
@property (nonatomic, assign, readonly, getter = isUserConsent) BOOL userConsent;

/**
 * User Consent string set by Consent Framework
 */
@property (nonatomic, strong) NSString * _Nullable userConsentString;

/**
 * Show LoopMe GDPR window to ask user consent.
 * Works only for EU users.
 */
- (void)showGDPRWindowFromViewController:(UIViewController * _Nonnull)viewController;

/**
 * If you know user consent in BOOL format, you can set it by this method.
 */
- (void)setCustomUserConsent:(BOOL)userConsent;
/**
 * Take appsource id 
 */
- (void)getAppDetailsFromServer;
- (LoopMeConsentType)consentType;

 /**
 * Methods provides by IAB In-App CMP API.
 * Read more: https://github.com/InteractiveAdvertisingBureau/GDPR-Transparency-and-Consent-Framework/blob/master/TCFv2/IAB%20Tech%20Lab%20-%20CMP%20API%20v2.md#what-does-the-gdprapplies-value-mean
 */
- (NSInteger)GDRRApplies;
- (NSString *_Nullable)consentString;
- (NSString *_Nullable)cmpSdkID;
- (NSString *_Nullable)sourceAppID;
@end
