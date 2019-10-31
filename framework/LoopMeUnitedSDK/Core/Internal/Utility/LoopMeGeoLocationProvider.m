//
//  LoopMeGeoLocationProvider.m
//  LoopMeSDK
//
//  Created by Kogda Bogdan on 1/19/15.
//
//

#import <CoreLocation/CoreLocation.h>

#import "LoopMeGeoLocationProvider.h"
#import "LoopMeDefinitions.h"
#import "LoopMeLogging.h"

const NSTimeInterval kLoopMeLocationUpdateLength = 15;

@interface LoopMeGeoLocationProvider ()
<
    CLLocationManagerDelegate
>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSTimer *updateLocationTimer;
@property (nonatomic, strong) NSDate *timeOfLastLocationUpdate;
@property (nonatomic, readwrite, strong) CLLocation *location;
@property (nonatomic, getter = isAuthorizedForLocationServices) BOOL authorizedForLocationServices;

- (BOOL)isValidLocation:(CLLocation *)inputLocation;

@end

@implementation LoopMeGeoLocationProvider

#pragma mark - Properties

- (void)setLocationUpdateEnabled:(BOOL)enabled {
    _locationUpdateEnabled = enabled;
    
    if (!_locationUpdateEnabled) {
        [self stopLocationUpdate];
        self.location = nil;
    } else if (![self.updateLocationTimer isValid]) {
        [self startLocationUpdate];
    }
}

- (void)setAuthorizedForLocationServices:(BOOL)authorizedForLocationServices {
    _authorizedForLocationServices = authorizedForLocationServices;
    
    if (_authorizedForLocationServices && [CLLocationManager locationServicesEnabled]) {
        [self startLocationUpdate];
    } else {
        [self stopLocationUpdate];
        self.location = nil;
    }
}

#pragma mark - Life Cylce

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.locationUpdateEnabled = YES;
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        
        _locationUpdateInterval = 300;
        
        if ([self isValidLocation:_locationManager.location]) {
            _location = _locationManager.location;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopLocationUpdate) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resumeLocationUpdate) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

#pragma mark - Class Methods

+ (LoopMeGeoLocationProvider *)sharedProvider {
    static LoopMeGeoLocationProvider *sharedProvider = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedProvider = [[[self class] alloc] init];
    });
    
    return sharedProvider;
}

#pragma mark - Private

- (void)startLocationUpdate {
    if (!self.isLocationUpdateEnabled) {
        return;
    }
    
    if (![CLLocationManager locationServicesEnabled] || ![self isAuthorizedStatus:[CLLocationManager authorizationStatus]]) {
        return;
    }
    
    self.timeOfLastLocationUpdate = [NSDate date];

    if (!self.location && [self isValidLocation:self.locationManager.location]) {
        self.location = self.locationManager.location;
    }
    
    [self.locationManager startUpdatingLocation];
    [self.updateLocationTimer invalidate];
    self.updateLocationTimer = nil;
    self.updateLocationTimer = [NSTimer scheduledTimerWithTimeInterval:kLoopMeLocationUpdateLength target:self selector:@selector(finishUpdateLocation) userInfo:nil repeats:NO];

}

- (void)finishUpdateLocation {
    [self.updateLocationTimer invalidate];
    self.updateLocationTimer = nil;
    [self.locationManager stopUpdatingLocation];
    
    if (_location) {
        [self scheduleNextLocationUpdateAfterDelay:self.locationUpdateInterval];
    } else {
        [self startLocationUpdate];
    }
}

- (void)scheduleNextLocationUpdateAfterDelay:(NSTimeInterval)delay {
    [self.updateLocationTimer invalidate];
    self.updateLocationTimer = nil;
    self.updateLocationTimer = [NSTimer scheduledTimerWithTimeInterval:delay target:self selector:@selector(startLocationUpdate) userInfo:nil repeats:NO];
}

- (void)stopLocationUpdate {
    [self.updateLocationTimer invalidate];
    self.updateLocationTimer = nil;
    [self.locationManager stopUpdatingLocation];
}

- (void)resumeLocationUpdate {
    if (_locationUpdateEnabled) {
        NSTimeInterval timeSinceLastUpdate = [[NSDate date] timeIntervalSinceDate:self.timeOfLastLocationUpdate];
        
        if (timeSinceLastUpdate >= self.locationUpdateInterval || !self.timeOfLastLocationUpdate || !self.location) {
            [self startLocationUpdate];
        } else if (timeSinceLastUpdate >= 0) {
            NSTimeInterval timeToNextUpdate = self.locationUpdateInterval - timeSinceLastUpdate;
            [self scheduleNextLocationUpdateAfterDelay:timeToNextUpdate];
        } else {
            [self scheduleNextLocationUpdateAfterDelay:self.locationUpdateInterval];
        }
    }
}

- (BOOL)isValidLocation:(CLLocation *)inputLocation {
    return inputLocation && inputLocation.horizontalAccuracy > 0;
}

- (BOOL)isAuthorizedStatus:(CLAuthorizationStatus)status {
    return (status == kCLAuthorizationStatusAuthorizedAlways) || (status == kCLAuthorizationStatusAuthorizedWhenInUse);
}

#pragma mark - public

- (BOOL)isValidLocation {
    return [self isValidLocation:self.location];
}

#pragma mark - CLLocation Helpers

- (BOOL)isLocation:(CLLocation *)location betterThanLocation:(CLLocation *)otherLocation {
    if (!otherLocation) {
        return YES;
    }
    
    // Nil locations and locations with invalid horizontal accuracy are worse than any location.
    if (![self locationHasValidCoordinates:location]) {
        return NO;
    }
    
    if ([self isLocation:location olderThanLocation:otherLocation]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)locationHasValidCoordinates:(CLLocation *)location {
    return location && location.horizontalAccuracy > 0;
}

- (BOOL)isLocation:(CLLocation *)location olderThanLocation:(CLLocation *)otherLocation {
    return [location.timestamp timeIntervalSinceDate:otherLocation.timestamp] < 0;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            self.authorizedForLocationServices = NO;
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            self.authorizedForLocationServices = YES;
            break;
        default:
            self.authorizedForLocationServices = NO;
            break;
    }
}
 
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
     for (CLLocation *location in locations) {
         if ([self isLocation:location betterThanLocation:self.location]) {
             self.location = location;
         }
     }
}
 
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (error.code == kCLErrorDenied) {
        [self stopLocationUpdate];
    }
}

@end
