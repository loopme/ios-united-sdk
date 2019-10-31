//
//  LoopMeCacnelView.m
//  LoopMeSDK
//
//  Created by Dmitriy Lihachov on 8/21/12.
//  Copyright (c) 2012 LoopMe. All rights reserved.
//

#import "LoopMeCancelView.h"

@implementation LoopMeCancelView

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
    [bezierPath moveToPoint: CGPointMake(0, 0)];

    [bezierPath addLineToPoint: CGPointMake(rect.size.width, rect.size.height)];
    [[UIColor redColor] setStroke];
    bezierPath.lineWidth = 1;
    [bezierPath stroke];
    
    UIBezierPath* bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint: CGPointMake(rect.size.width, 0)];
    [bezier2Path addLineToPoint: CGPointMake(0, rect.size.height)];
    [[UIColor redColor] setStroke];
    bezier2Path.lineWidth = 1;
    [bezier2Path stroke];
}
@end
