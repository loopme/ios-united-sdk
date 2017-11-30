//
//  LoopMeNavigationBack.m
//  LoopMeSDK
//
//  Created by Dmitriy Lihachov on 8/21/12.
//  Copyright (c) 2012 LoopMe. All rights reserved.
//

#import "LoopMeBackView.h"

@implementation LoopMeBackView

#pragma mark - Life Cycle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - Properties

- (void)setActive:(BOOL)active {
    _active = active;
    [self setNeedsDisplay];
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    UIColor *backgroundColor;
    if (self.isActive) {
        backgroundColor = [UIColor colorWithRed:0.278 green:0.529 blue:0.933 alpha:1]; //#4787ee
    } else {
        backgroundColor = [UIColor colorWithRed:0.408 green:0.408 blue:0.408 alpha:1];  //#686868
    }
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint: CGPointMake(17.5, 1.5)];
    [bezierPath addCurveToPoint: CGPointMake(6.5, 14.46) controlPoint1: CGPointMake(6.5, 14.46) controlPoint2: CGPointMake(6.5, 14.46)];
    [bezierPath addCurveToPoint: CGPointMake(17.5, 26.5) controlPoint1: CGPointMake(6.5, 14.46) controlPoint2: CGPointMake(17.5, 26.44)];
    [backgroundColor setStroke];
    bezierPath.lineWidth = 2;
    [bezierPath stroke];
}

@end
