//
//  AvidManagedVideoAdSession.h
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 05/04/16.
//  Copyright © 2016 Integral. All rights reserved.
//

#import "LoopMe_AbstractAvidManagedAdSession.h"
#import "LoopMe_AvidVideoPlaybackListener.h"

@interface LoopMe_AvidManagedVideoAdSession : LoopMe_AbstractAvidManagedAdSession

@property(nonatomic, readonly) id<LoopMe_AvidVideoPlaybackListener> avidVideoPlaybackListener;

@end
