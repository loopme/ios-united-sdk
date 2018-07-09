//
//  LoopMeOrientationViewControllerProtocol.h
//  LoopMeSDK
//
//  Created by Bohdan on 12/7/17.
//  Copyright © 2017 LoopMe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoopMeAdConfiguration.h"

@protocol LoopMeOrientationViewControllerProtocol <NSObject>

- (void)setOrientation:(LoopMeAdOrientation)orientation;
- (void)setAllowOrientationChange:(BOOL)autorotate;
- (void)forceChangeOrientation;

@end
