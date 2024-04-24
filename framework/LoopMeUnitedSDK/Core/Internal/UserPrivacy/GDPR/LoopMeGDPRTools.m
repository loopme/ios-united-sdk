//
//  LoopMeGDPRTools.m
//  LoopMeSDK
//
//  Created by Bohdan on 4/12/18.
//  Copyright © 2018 LoopMe. All rights reserved.
//

#import "LoopMeGDPRTools.h"
#import "LoopMeIdentityProvider.h"

typedef struct {
    BOOL userConsent;
    BOOL needConsent;
    LoopMeConsentType consentType;
} LoopMeConsentResult;

static NSString * const kLoopMeNeedConsentKey = @"need_consent";
static NSString * const kLoopMeUserConsentKey = @"user_consent";
static NSString * const kLoopMeConsentURLKey = @"consent_url";

static NSString * const kLoopMeUserDefaultsGDPRKey = @"LoopMeGDPRFlag";
static NSString * const kLoopMeUserDefaultsGDPRWindowKey = @"LoopMeGDPRWindowFlag";

static NSString * const kLoopMeIABUserDefaultsKeyCMPSdkId = @"IABTCF_CmpSdkID";
static NSString * const kLoopMeIABUserDefaultsKeyGdprApplies = @"IABTCF_gdprApplies";
static NSString * const kLoopMeIABUserDefaultsKeyConsentString = @"IABTCF_TCString";
static NSString * const kLoopMeSourceAppID = @"SourceAppID";

@interface LoopMeGDPRTools()

@property (nonatomic, assign) BOOL userConsent;

@property (nonatomic) LoopMeConsentType consentType;
@property (nonatomic) void (^completionBlock)(void);

@end

@implementation LoopMeGDPRTools

+ (instancetype)sharedInstance {
    static LoopMeGDPRTools *instance;
    if (!instance) {
        instance = [[LoopMeGDPRTools alloc] init];
        if (![[NSUserDefaults standardUserDefaults] objectForKey: kLoopMeUserDefaultsGDPRKey]) {
            [[NSUserDefaults standardUserDefaults] setBool: NO forKey: kLoopMeUserDefaultsGDPRKey];
        }
        instance.consentType = LoopMeConsentTypeDidNotSet;
    }
    return instance;
}

- (NSString *)userConsentString {
    if (!_userConsentString) {
        if ([self cmpSdkID] && [self GDRRApplies]) {
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

- (void)prepareConsent {
    if (![LoopMeIdentityProvider advertisingTrackingEnabled]) {
        self.consentType = LoopMeConsentTypeUserRestricted;
        return;
    }
    if (self.consentType != LoopMeConsentTypeDidNotSet) {
        return;
    }
    // Code below calling getter, so, do not touch this entire method till defining expected behavior for this method
    // It's not clear and hard to understand
    if (self.userConsentString) {
        return;
    }
}

- (void)getAppDetailsFromServer {
    // Retrieve bundle identifier
    NSString *bundleIdentifier = [[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"];
    NSString *baseURL = [NSString stringWithFormat: @"http://itunes.apple.com/lookup?bundleId=%@", bundleIdentifier];
    NSString *encodedURL = [baseURL stringByAddingPercentEncodingWithAllowedCharacters: [NSCharacterSet URLQueryAllowedCharacterSet]];
    
    // Creating URL Object
    NSURL *url = [NSURL URLWithString: encodedURL];
    // Creating a Mutable Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url];
    // Setting HTTP values
    [request setHTTPMethod: @"GET"];
    [request setTimeoutInterval: 120];
    
    // Creating URLSession
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration: configuration];
    
    // Creating Data Task
    [[session dataTaskWithRequest: request
                completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil || data == nil) {
            NSLog(@"Error fetching data: %@", error.localizedDescription);
            return;
        }        
        NSArray *results = [NSJSONSerialization JSONObjectWithData: data
                                                           options: NSJSONReadingMutableContainers
                                                             error: &error][@"results"];
        if (results.count > 0) {
            NSString *appId = [NSString stringWithFormat: @"%@", results[0][@"trackId"]];
            [[NSUserDefaults standardUserDefaults] setObject: appId forKey: kLoopMeSourceAppID];
            NSLog(@"App ID: %@", appId);
        } else {
            NSLog(@"No results found in the response");
        }
    }] resume];
}

#pragma mark CMP tools

- (NSInteger)GDRRApplies {
    if ([[NSUserDefaults standardUserDefaults] valueForKey: kLoopMeIABUserDefaultsKeyGdprApplies]) {
        return [[NSUserDefaults standardUserDefaults] integerForKey: kLoopMeIABUserDefaultsKeyGdprApplies];
    }
    return -1;
}

- (NSString *)consentString {
    return [[NSUserDefaults standardUserDefaults] stringForKey: kLoopMeIABUserDefaultsKeyConsentString];
}

- (NSString *)cmpSdkID {
    return [[NSUserDefaults standardUserDefaults] stringForKey: kLoopMeIABUserDefaultsKeyCMPSdkId];
}
- (NSString *)sourceAppID {
    return [[NSUserDefaults standardUserDefaults] stringForKey: kLoopMeSourceAppID];
}

+ (NSString *)getConsentValue {
    LoopMeGDPRTools *gdpr = [LoopMeGDPRTools sharedInstance];
    if ([gdpr userConsentString]) {
        return [gdpr userConsentString];
    }
    return ([LoopMeIdentityProvider advertisingTrackingEnabled] && [gdpr isUserConsent]) ? @"1" : @"0";
}

@end
