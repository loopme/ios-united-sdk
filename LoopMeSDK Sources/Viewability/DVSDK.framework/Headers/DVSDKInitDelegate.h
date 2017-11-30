//
//  DVSDKInitDelegate.h
//  DVSDK
//
//  Created by Daniel Gorlovetsky on 06/11/2016.
//  Copyright © 2016 DoubleVerify. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef DVSDKInitDelegate_h
#define DVSDKInitDelegate_h

@protocol DVSDKInitDelegate <NSObject>

- (void)initFinished;

@end

#endif /* DVSDKInitDelegate */