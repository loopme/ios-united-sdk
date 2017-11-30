//
//  LoopMe360ViewController.h
//  LoopMe
//
//  Created by Bohdan on 4/25/16.
//  Copyright © 2016 LoopMe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@protocol LoopMe360ToolsProtocol;

@interface LoopMe360ViewController : GLKViewController

@property (weak, nonatomic)  id<LoopMe360ToolsProtocol> customDelegate;
- (void)pan:(CGPoint)location prevLocation:(CGPoint)prevLocation;
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer;

@end

@protocol LoopMe360ToolsProtocol <NSObject>

- (CVPixelBufferRef)retrievePixelBufferToDraw;
- (void)track360FrontSector;
- (void)track360BackSector;
- (void)track360LeftSector;
- (void)track360RightSector;
- (void)track360Gyro;
- (void)track360Swipe;
- (void)track360Zoom;

@end