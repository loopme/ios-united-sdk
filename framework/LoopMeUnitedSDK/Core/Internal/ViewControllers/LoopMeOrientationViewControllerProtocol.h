//
//  LoopMeOrientationViewControllerProtocol.h
//  LoopMeSDK
//
//  Created by Bohdan on 12/7/17.
//  Copyright © 2017 LoopMe. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LoopMeOrientationViewControllerProtocol <NSObject>

//LoopMeAdOrientation
- (void)setOrientation:(NSInteger)orientation;
- (void)setAllowOrientationChange:(BOOL)autorotate;
- (void)forceChangeOrientation;

@end
