//
//  LoopMeGDPRTools.m
//  LoopMeSDK
//
//  Created by Bohdan on 4/12/18.
//  Copyright © 2018 LoopMe. All rights reserved.
//

#import "LoopMeGDPRTools.h"
#import "LoopMeIdentityProvider.h"
#import "LoopMeGDPRAPIService.h"
#import "LoopMeGDPRViewController.h"

static NSString * const kLoopMeUserDefaultsGDPRKey = @"LoopMeGDPRFlag";
static NSString * const kLoopMeUserDefaultsGDPRWindowKey = @"LoopMeGDPRWindowFlag";

static NSString * const kLoopMeIABUserDefaultsKeyCMPPresent = @"IABConsent_CMPPresent";
static NSString * const kLoopMeIABUserDefaultsKeySubjectToGDPR = @"IABConsent_SubjectToGDPR";
static NSString * const kLoopMeIABUserDefaultsKeyConsentString = @"IABConsent_ConsentString";

@interface LoopMeGDPRTools() <LoopMeGDPRViewControllerDelegate>

@property (nonatomic) NSString *userConsentString;

@property (nonatomic, assign) BOOL userConsent;

@property (nonatomic) LoopMeGDPRViewController *gdprVC;
@property (nonatomic) LoopMeConsentType consentType;
@property (nonatomic) void (^completionBlock)(void);

@end


@implementation LoopMeGDPRTools

+ (instancetype)sharedInstance {
    static LoopMeGDPRTools *instance;
    if (!instance) {
        instance = [[LoopMeGDPRTools alloc] init];
        if (![[NSUserDefaults standardUserDefaults] objectForKey:kLoopMeUserDefaultsGDPRKey]) {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kLoopMeUserDefaultsGDPRKey];
        }
        instance.consentType = LoopMeConsentTypeDidNotSet;
    }
    return instance;
}

- (NSString *)userConsentString {
    if (!_userConsentString) {
        if ([self cmpPresent] && [self subjectToGDPR]) {
            _userConsentString = [self consentString];
        }
    }
    
    return _userConsentString;
}

- (BOOL)isUserConsent {
    return _userConsent;
}

- (void)setCustomUserConsent:(BOOL)userConsent{
    self.consentType = LoopMeConsentTypePublisher;
    _userConsent = userConsent;
}

- (void)showGDPRWindowFromViewController:(UIViewController *)viewController {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (![LoopMeIdentityProvider advertisingTrackingEnabled]) {
            self.consentType = LoopMeConsentTypeUserRestricted;
            return;
        }
        
        if (self.consentType != LoopMeConsentTypeDidNotSet) {
            return;
        }
        
        if (self.userConsentString) {
            return;
        }
        
        if (![LoopMeGDPRAPIService isNeedUserConsent:[LoopMeIdentityProvider advertisingTrackingDeviceIdentifier]]) {
            [self checkUserConsent];
            return;
        }
        
        self.consentType = LoopMeConsentTypeFailedAPI;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.gdprVC = [[LoopMeGDPRViewController alloc] initWithURL:[LoopMeGDPRAPIService consentURL:[LoopMeIdentityProvider advertisingTrackingDeviceIdentifier]]];
            self.gdprVC.delegate = self;
            [viewController presentViewController:self.gdprVC animated:YES completion:nil];
        });
    });
}

- (void)loopMeGDPRViewControllerDidDisapper {
    [self checkUserConsent];
}

- (void)checkUserConsent {
    LoopMeConsentType type;
    self.userConsent = [LoopMeGDPRAPIService userConsent:[LoopMeIdentityProvider advertisingTrackingDeviceIdentifier] consentType:&type];
    self.consentType = type;
}

#pragma mark CMP tools


- (BOOL)cmpPresent {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kLoopMeIABUserDefaultsKeyCMPPresent];
}

- (NSString *)subjectToGDPR {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kLoopMeIABUserDefaultsKeySubjectToGDPR];
}

- (NSString *)consentString {
    return [[NSUserDefaults standardUserDefaults] stringForKey:kLoopMeIABUserDefaultsKeyConsentString];
}

@end