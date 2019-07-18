//
//  LoopMeUtility.h
//  LoopMeSDK
//
//  Created by Dmitriy Lihachov on 8/21/12.
//  Copyright (c) 2012 LoopMe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoopMeLogging.h"
#import "LoopMeDefinitions.h"
#import "LoopMeServerURLBuilder.h"
#import "LoopMeGlobalSettings.h"
#import "LoopMeIdentityProvider.h"

@class LoopMeLoggingSender;

static NSString *kLoopMeUserDefaultsDateKey = @"loopMeLogWriteDate";
static LoopMeLogLevel logLevel = LoopMeLogLevelOff;

LoopMeLogLevel getLoopMeLogLevel() {
    return logLevel;
}

void setLoopMeLogLevel(LoopMeLogLevel level) {
    logLevel = level;
}

void LoopMeLogDebug(NSString *format, ...) {
    if (logLevel <= LoopMeLogLevelDebug) {
        format = [NSString stringWithFormat:@"LoopMe: %@", format];
        va_list args;
        va_start(args, format);
        NSString *logStr = [[NSString alloc] initWithFormat:format arguments:args];
        [[LoopMeLoggingSender sharedInstance] writeLog:logStr];
        NSLog(@"%@", logStr);
        va_end(args);
    }
}

void LoopMeLogInfo(NSString *format, ...) {
    if (logLevel <= LoopMeLogLevelInfo) {
        format = [NSString stringWithFormat:@"LoopMe: %@", format];
        va_list args;
        va_start(args, format);
        NSString *logStr = [[NSString alloc] initWithFormat:format arguments:args];
        [[LoopMeLoggingSender sharedInstance] writeLog:logStr];
        NSLog(@"%@", logStr);
        va_end(args);
    }
}

void LoopMeLogError(NSString *format, ...) {
    if (logLevel <= LoopMeLogLevelError) {
        format = [NSString stringWithFormat:@"LoopMe: %@", format];
        va_list args;
        va_start(args, format);
        NSString *logStr = [[NSString alloc] initWithFormat:format arguments:args];
        [[LoopMeLoggingSender sharedInstance] writeLog:logStr];
        NSLog(@"%@", logStr);
        va_end(args);
    }
}

@interface LoopMeLoggingSender ()

@property (nonatomic) NSFileHandle *logHandle;
@property (nonatomic) NSURLSession *session;
@property (nonatomic) NSString *logFilePath;

@end

@implementation LoopMeLoggingSender

static dispatch_semaphore_t sema; // The semaphore
static dispatch_once_t onceToken;

+ (LoopMeLoggingSender *)sharedInstance {
    static LoopMeLoggingSender *sender = nil;
    if (!sender) {
        sender = [[LoopMeLoggingSender alloc] init];
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kLoopMeUserDefaultsDateKey];
    }
    return sender;
}

- (void)dealloc {

}

- (instancetype)init {
    self = [super init];
    if (self) {
        dispatch_once(&onceToken, ^{
            // Initialize with count=1 (this is executed only once):
            sema = dispatch_semaphore_create(1);
        });
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:nil];
    }
    return self;
}

- (NSFileHandle *)logHandle {
    if (!_logHandle) {
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.logFilePath]) {
            [[NSFileManager defaultManager] createFileAtPath:self.logFilePath contents:nil attributes:nil];
        }
        _logHandle = [NSFileHandle fileHandleForWritingAtPath:self.logFilePath];
    }
    return _logHandle;
}

- (NSString *)logs {
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.logFilePath]) {
        NSString *logString = [[NSString alloc] initWithContentsOfFile:self.logFilePath encoding:NSUTF8StringEncoding error:nil];
        logString = [logString stringByReplacingOccurrencesOfString:@"=" withString:@"equal"];
        logString = [logString stringByReplacingOccurrencesOfString:@"&" withString:@"and"];
        return logString;
    }
    
    return @"";
}

- (NSString *)logFilePath {
    if (!_logFilePath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        documentsDirectory = [documentsDirectory stringByAppendingPathComponent:@"lm_assets/"];
        _logFilePath = [documentsDirectory stringByAppendingPathComponent:@"loopmelog.lm"];
    }
    return _logFilePath;
}

- (void)writeLog:(NSString *)msg {
    if (![LoopMeGlobalSettings sharedInstance].isLiveDebugEnabled) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *adjustedMsg = [NSString stringWithFormat:@"\n%@", msg];
        [self.logHandle writeData:[adjustedMsg dataUsingEncoding:NSUTF8StringEncoding]];
        [self sendLog];
    });
}

- (void)removeLogs {
    [[NSFileManager defaultManager] removeItemAtPath:self.logFilePath error:nil];
    self.logHandle = nil;
}

- (void)sendLog {
    if (![LoopMeGlobalSettings sharedInstance].isLiveDebugEnabled) {
        return;
    }
    NSDate *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:kLoopMeUserDefaultsDateKey];
    int intervall = (int) [lastDate timeIntervalSinceNow] / 60;
    if (abs(intervall) >= 3) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kLoopMeUserDefaultsDateKey];
        if (dispatch_semaphore_wait(sema, DISPATCH_TIME_NOW) == 0) {
            [self startSendingTask];
        }
    }
}

- (void)startSendingTask {
    NSURL *url = [NSURL URLWithString:@"https://tk0x1.com/api/errors"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"UTF-8" forHTTPHeaderField:@"Content-Encoding"];
    
    
    NSString *params = [NSString stringWithFormat:@"device_os=ios&sdk_type=loopme&sdk_version=%@&device_id=%@&package=%@&app_key=%@&msg=sdk_debug&debug_logs=%@", LOOPME_SDK_VERSION, [LoopMeIdentityProvider advertisingTrackingDeviceIdentifier], [NSBundle mainBundle].bundleIdentifier, [LoopMeGlobalSettings sharedInstance].appKeyForLiveDebug, [self logs]];
    
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionDataTask *postDataTask = [self.session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        [self removeLogs];
        dispatch_semaphore_signal(sema);
        
    }];

    [postDataTask resume];
}

@end
