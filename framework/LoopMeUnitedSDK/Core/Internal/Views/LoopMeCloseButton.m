//
//  LoopMeCloseButton.m
//  LoopMeSDK
//
//  Created by Bohdan Korda on 10/24/16.
//  Copyright (c) 2016 LoopMe. All rights reserved.
//

#import "LoopMeCloseButton.h"

@implementation LoopMeCloseButton

#pragma mark - Life Cycle

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

#pragma mark - Private

- (void)drawRect:(CGRect)rect {
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];  
    [bezierPath moveToPoint: CGPointMake(rect.size.width/2 - LOOP_ME_CLOSE_SIZE/2, rect.size.height/2 - LOOP_ME_CLOSE_SIZE/2)];
    [bezierPath addLineToPoint:CGPointMake(rect.size.width/2 + LOOP_ME_CLOSE_SIZE/2, rect.size.height/2 + LOOP_ME_CLOSE_SIZE/2)];
    
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(rect.size.width/2 - LOOP_ME_CLOSE_SIZE/2, rect.size.height/2 + LOOP_ME_CLOSE_SIZE/2)];
    [bezier2Path addLineToPoint: CGPointMake(rect.size.width/2 + LOOP_ME_CLOSE_SIZE/2, rect.size.height/2 - LOOP_ME_CLOSE_SIZE/2)];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] setStroke];
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    
    CGContextSetLineWidth(context, 6.0);
    CGContextAddPath(context, bezier2Path.CGPath);
    CGContextAddPath(context, bezierPath.CGPath);
    CGContextStrokePath(context);
    
    [[UIColor whiteColor] setStroke];
    CGContextSetLineWidth(context, 4.0);
    CGContextAddPath(context, bezier2Path.CGPath);
    CGContextAddPath(context, bezierPath.CGPath);
    CGContextStrokePath(context);
}
@end
