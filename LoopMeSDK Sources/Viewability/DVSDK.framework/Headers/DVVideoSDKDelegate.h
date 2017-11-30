//
//  DVVideoSDKDelegate.h
//  DVSDK
//
//  Created by Daniel Gorlovetsky on 26/07/2016.
//  Copyright © 2016 DoubleVerify. All rights reserved.
//

#ifndef DVVideoSDKDelegate_h
#define DVVideoSDKDelegate_h

@protocol DVVideoSDKDelegate <NSObject>

@optional
- (void)dvAdMeasured:(NSString *)adId;
- (void)dvAdImpression:(NSString *)adId;
- (void)dvAdViewed:(NSString *)adId;
@end

#endif /* DVVideoSDKDelegate_h */
