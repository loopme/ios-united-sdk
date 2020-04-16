/*

 File: Reachability.m
 Abstract: Basic demonstration of how to use the SystemConfiguration Reachablity APIs.

 Version: 2.2

 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and your
 use, installation, modification or redistribution of this Apple software
 constitutes acceptance of these terms.  If you do not agree with these terms,
 please do not use, install, modify or redistribute this Apple software.

 In consideration of your agreement to abide by the following terms, and subject
 to these terms, Apple grants you a personal, non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple Software"), to
 use, reproduce, modify and redistribute the Apple Software, with or without
 modifications, in source and/or binary forms; provided that if you redistribute
 the Apple Software in its entirety and without modifications, you must retain
 this notice and the following text and disclaimers in all such redistributions
 of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may be used
 to endorse or promote products derived from the Apple Software without specific
 prior written permission from Apple.  Except as expressly stated in this notice,
 no other rights or licenses, express or implied, are granted by Apple herein,
 including but not limited to any patent rights that may be infringed by your
 derivative works or by other works in which the Apple Software may be
 incorporated.

 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
 WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
 WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
 COMBINATION WITH YOUR PRODUCTS.

 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
 DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
 CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
 APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 Copyright (C) 2010 Apple Inc. All Rights Reserved.

*/

#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

#import <CoreFoundation/CoreFoundation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTCall.h>
#import <CoreTelephony/CTCallCenter.h>
#import <SystemConfiguration/CaptiveNetwork.h>

#import "LoopMeReachability.h"
#import "LoopMeLogging.h"

typedef NS_ENUM(NSUInteger, LoopMeReachabilityNetworkStatus) {
    LoopMeReachabilityNotReachable = 0,
    LoopMeReachabilityReachableViaWiFi,
    LoopMeReachabilityReachableViaWWAN,
};

@implementation LoopMeReachability

#pragma mark - Life Cycle

- (void)dealloc {
    if(reachabilityRef!= NULL) {
        CFRelease(reachabilityRef);
    }
}

#pragma mark - Public Class

+ (LoopMeReachability *) reachabilityForLocalWiFi {
    struct sockaddr_in localWifiAddress;
    bzero(&localWifiAddress, sizeof(localWifiAddress));
    localWifiAddress.sin_len = sizeof(localWifiAddress);
    localWifiAddress.sin_family = AF_INET;
    // IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0
    localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
    LoopMeReachability* retVal = [self reachabilityWithAddress: &localWifiAddress];
    if(retVal!= NULL) {
        retVal->localWiFiRef = YES;
    }
    return retVal;
}

#pragma mark - Private 

+ (LoopMeReachability *)reachabilityWithAddress: (const struct sockaddr_in*) hostAddress {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)hostAddress);
    LoopMeReachability *retVal = NULL;
    if (reachability!= NULL) {
        retVal= [[self alloc] init];
        if (retVal!= NULL) {
            retVal->reachabilityRef = reachability;
            retVal->localWiFiRef = NO;
        }
    }
    return retVal;
}

#pragma mark Network Flag Handling

- (LoopMeReachabilityNetworkStatus)localWiFiStatusForFlags: (SCNetworkReachabilityFlags) flags {
    BOOL retVal = LoopMeReachabilityNotReachable;
    if ((flags & kSCNetworkReachabilityFlagsReachable) && (flags & kSCNetworkReachabilityFlagsIsDirect)) {
        retVal = LoopMeReachabilityReachableViaWiFi;
    }
    return retVal;
}

- (LoopMeReachabilityNetworkStatus) networkStatusForFlags: (SCNetworkReachabilityFlags) flags {
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
        // if target host is not reachable
        return LoopMeReachabilityNotReachable;
    }

    BOOL retVal = LoopMeReachabilityNotReachable;

    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0) {
        // if target host is reachable and no connection is required
        //  then we'll assume (for now) that your on Wi-Fi
        retVal = LoopMeReachabilityReachableViaWiFi;
    }


    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
        (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
            // ... and the connection is on-demand (or on-traffic) if the
            //     calling application is using the CFSocketStream or higher APIs

            if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
                // ... and no [user] intervention is needed
                retVal = LoopMeReachabilityReachableViaWiFi;
            }
        }

    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
        // ... but WWAN connections are OK if the calling application
        //     is using the CFNetwork (CFSocketStream?) APIs.
        retVal = LoopMeReachabilityReachableViaWWAN;
    }
    return retVal;
}

- (LoopMeReachabilityNetworkStatus)currentReachabilityStatus {
    NSAssert(reachabilityRef != NULL, @"currentNetworkStatus called with NULL reachabilityRef");
    LoopMeReachabilityNetworkStatus retVal = LoopMeReachabilityNotReachable;
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags)) {
        if(localWiFiRef) {
            retVal = [self localWiFiStatusForFlags: flags];
        } else {
            retVal = [self networkStatusForFlags: flags];
        }
    }
    return retVal;
}

- (BOOL)hasWifi {
    return [self currentReachabilityStatus] == LoopMeReachabilityReachableViaWiFi;
}

- (LoopMeConnectionType)connectionType {
    if ([self hasWifi]) {
        return LoopMeConnectionTypeWiFi;
    } else {
        CTTelephonyNetworkInfo *telephonyInfo = [CTTelephonyNetworkInfo new];

        if ([telephonyInfo respondsToSelector:@selector(currentRadioAccessTechnology)]) {
            NSString *radioAccessTechnology = telephonyInfo.currentRadioAccessTechnology;
            
            if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS] || [radioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge]) {
                return LoopMeConnectionTypeCellular2G;
            } else if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyWCDMA]        ||
                       [radioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSDPA]        ||
                       [radioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSUPA]        ||
                       [radioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMA1x]       ||
                       [radioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0] ||
                       [radioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA] ||
                       [radioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB] ||
                       [radioAccessTechnology isEqualToString:CTRadioAccessTechnologyeHRPD]) {
                return LoopMeConnectionTypeCellular3G;
            } else if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
                return LoopMeConnectionTypeCellular4G;
            }
        }
        return LoopMeConnectionTypeCellularUnknown;
    }
    return LoopMeConnectionTypeUnknown;
}

- (NSString *)getSSID {
    NSDictionary *info = [self fetchSSIDInfo];
    if (info) {
        return info[@"SSID"];
    }
    return @"unknown";
}

- (NSDictionary *)fetchSSIDInfo {
    NSArray *interfaceNames = CFBridgingRelease(CNCopySupportedInterfaces());
    LoopMeLogDebug(@"%s: Supported interfaces: %@", __func__, interfaceNames);
    
    NSDictionary *SSIDInfo;
    for (NSString *interfaceName in interfaceNames) {
        SSIDInfo = CFBridgingRelease(
                                     CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName));
        LoopMeLogDebug(@"%s: %@ => %@", __func__, interfaceName, SSIDInfo);
        
        BOOL isNotEmpty = (SSIDInfo.count > 0);
        if (isNotEmpty) {
            break;
        }
    }
    return SSIDInfo;
}

@end
