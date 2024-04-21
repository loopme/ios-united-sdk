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

typedef struct {
    BOOL userConsent;
    BOOL needConsent;
    LoopMeConsentType consentType;
    NSURL * _Nullable consentUrl;
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

@interface LoopMeGDPRTools() <LoopMeGDPRViewControllerDelegate>

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

- (LoopMeConsentResult)resultFrom: (NSDictionary *)dictionary deviceID:(NSString *)deviceID {
    NSString *consentUrl = [dictionary objectForKey: kLoopMeConsentURLKey];
    NSString *needConsent = [dictionary objectForKey: kLoopMeNeedConsentKey];
    return (LoopMeConsentResult){
        .userConsent = [[dictionary objectForKey: kLoopMeUserConsentKey] boolValue],
        .consentType = LoopMeConsentTypeLoopMe,
        .needConsent = needConsent ? [needConsent boolValue] : NO,
        .consentUrl = consentUrl ? [NSURL URLWithString: [NSString stringWithFormat: @"%@?is_sdk=true&device_id=%@", consentUrl, deviceID]] : nil
    };
}

- (LoopMeConsentResult)userConsent: (NSString *)deviceID {
    NSDictionary *resultDict = [LoopMeGDPRAPIService apiResponse: deviceID ignoreCache: NO];
    if ([resultDict objectForKey: kLoopMeUserConsentKey]) {
        return [self resultFrom: resultDict deviceID: deviceID];
    }
    // Check again without cache
    NSDictionary *resultDict2 = [LoopMeGDPRAPIService apiResponse: deviceID ignoreCache: YES];
    if ([resultDict2 objectForKey: kLoopMeUserConsentKey]) {
        return [self resultFrom: resultDict2 deviceID: deviceID];
    }

    return (LoopMeConsentResult){
        .userConsent = NO,
        .consentType = LoopMeConsentTypeFailedAPI,
        .consentUrl = nil,
        .needConsent = NO
    };
}

- (void)showGDPRWindowFromViewController:(UIViewController *)viewController {
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

    NSString *deviceID = [LoopMeIdentityProvider advertisingTrackingDeviceIdentifier];
    LoopMeConsentResult result = [self userConsent: deviceID];

    if (!result.needConsent) {
        self.userConsent = result.userConsent;
        self.consentType = result.consentType;
        return;
    }
    
    self.consentType = LoopMeConsentTypeFailedAPI;
    
    if (!result.consentUrl) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.gdprVC = [[LoopMeGDPRViewController alloc] initWithURL: result.consentUrl];
        self.gdprVC.delegate = self;
        UIViewController *controller = [UIApplication sharedApplication].keyWindow.rootViewController;
        [controller presentViewController: self.gdprVC animated: YES completion: nil];
    });
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

- (void)loopMeGDPRViewControllerDidDisapper {
    NSString *deviceID = [LoopMeIdentityProvider advertisingTrackingDeviceIdentifier];
    LoopMeConsentResult result = [self userConsent: deviceID];
    self.userConsent = result.userConsent;
    self.consentType = result.consentType;
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
@end
