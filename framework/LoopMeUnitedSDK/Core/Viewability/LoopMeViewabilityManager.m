//
//  LoopMeViewabilityManager.m
//  LoopMeSDK
//
//  Created by Bohdan on 1/10/18.
//  Copyright © 2018 loopmemedia. All rights reserved.
//

#import "LoopMeViewabilityManager.h"

@interface LoopMeViewabilityManager()

@property (nonatomic, weak) UIView *view;

@end

@implementation LoopMeViewabilityManager

+ (instancetype)sharedInstance {
    static LoopMeViewabilityManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LoopMeViewabilityManager alloc] init];
    });
    return manager;
}

- (BOOL)isViewable:(UIView *)view {
    _visiblePersentage = 100;
    self.view = view;
    CGRect actualViewFrame = [view convertRect:view.bounds toView:nil];
    CGRect windowFrame = [[UIApplication sharedApplication].keyWindow frame];
    if ([self isRect:actualViewFrame intersectsRect:windowFrame]) {
        NSInteger areaRect = actualViewFrame.size.width * actualViewFrame.size.height;
        NSInteger intersectionArea = [self intersectionArea:actualViewFrame with:windowFrame];
        NSInteger visible = intersectionArea * 100 / areaRect;
        
        _visiblePersentage = visible;
        
        if ([self moreThenHalfOfRect:actualViewFrame visibleInRect:windowFrame]) {
            return NO;
        }
    } else {
        return NO;
    }
    
    return [self isRectVisible:actualViewFrame inWindow:self.view.window];
}

- (BOOL)isRect:(CGRect)rect intersectsRect:(CGRect)visibleRect {
    return CGRectIntersectsRect(rect, visibleRect);
}

- (BOOL)moreThenHalfOfRect:(CGRect)rect visibleInRect:(CGRect)visibleRect {
    return !(CGRectContainsPoint(visibleRect, CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))));
}

- (BOOL)isRectVisible:(CGRect)rect inWindow:(UIWindow *)window {

    CGPoint a = CGPointMake(rect.origin.x, rect.origin.y);
    CGPoint b = CGPointMake(rect.origin.x + rect.size.width - 1, rect.origin.y);
    CGPoint c = CGPointMake(rect.origin.x + rect.size.width - 1, rect.origin.y + rect.size.height - 1);
    CGPoint d = CGPointMake(rect.origin.x, rect.origin.y + rect.size.height - 1);
    CGPoint e = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    CGPoint f = CGPointMake(CGRectGetMidX(rect), rect.origin.y);
    CGPoint g = CGPointMake(CGRectGetMidX(rect), rect.origin.y + rect.size.height - 1);
    CGPoint h = CGPointMake(rect.origin.x, CGRectGetMidY(rect));
    CGPoint i = CGPointMake(rect.origin.x + rect.size.width - 1, CGRectGetMidY(rect));
    
    NSArray *points = @[[NSValue valueWithCGPoint:a], [NSValue valueWithCGPoint:b], [NSValue valueWithCGPoint:c], [NSValue valueWithCGPoint:d], [NSValue valueWithCGPoint:e], [NSValue valueWithCGPoint:f], [NSValue valueWithCGPoint:g], [NSValue valueWithCGPoint:h], [NSValue valueWithCGPoint:i]];
    
    NSMutableSet *hittestViews = [NSMutableSet new];
    
    for (NSValue *v in points) {
        UIView *view = [window hitTest:[v CGPointValue] withEvent:nil];
        if (view) {
            [hittestViews addObject:view];
        }
    }
    
    NSInteger noChildIntersectionAreaSum = 0;
    for (UIView *view in hittestViews) {
        if (![self isChildOrEqual:view of:self.view]) {
            noChildIntersectionAreaSum += [self intersectionArea:view.frame with:rect];
        }
    }
    
    NSInteger areaRect = rect.size.width * rect.size.height;
    NSInteger hiddenPercentage = noChildIntersectionAreaSum * 100 / areaRect;
    
    _visiblePersentage = self.visiblePersentage - hiddenPercentage;
    if (self.visiblePersentage < 50) {
        return NO;
    }
    return YES;
}

- (BOOL)isChildOrEqual:(UIView *)child of:(UIView *)view {
    return [child isDescendantOfView:view] || [child isKindOfClass:[UIScrollView class]] || [[child class] isSubclassOfClass:[UIScrollView class]];
}

- (NSInteger)intersectionArea:(CGRect)rect1 with:(CGRect)rect2 {
    CGRect intersect = CGRectIntersection(rect1, rect2);
    NSInteger intersectionArea = intersect.size.width * intersect.size.height;
    return intersectionArea;
}

@end
