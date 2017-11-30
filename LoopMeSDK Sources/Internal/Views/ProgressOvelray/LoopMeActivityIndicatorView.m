//
//  LoopMeProgressOverlayView.m
//  LoopMeSDK
//
//  Copyright (c) 2013 LoopMe. All rights reserved.
//

#import "LoopMeActivityIndicatorView.h"

@interface LoopMeActivityIndicatorView()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger currentStep;
@property (nonatomic, assign, getter = isAnimating) BOOL animating;
@property (nonatomic, assign, getter = isReverse) BOOL reverse;
@property (nonatomic, assign, getter = isRepeated) BOOL repeated;

- (UIColor*)currentBorderColor:(NSInteger)index;
- (UIColor*)currentInnerColor:(NSInteger)index;
- (CGRect)currentRect:(NSInteger)index;
- (void)repeatAnimation;

@end

@implementation LoopMeActivityIndicatorView

#pragma mark - Life Cycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setDefaultProperty];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (instancetype)init {
    self = [self initWithFrame:CGRectMake(0, 0, 20, 10)];
    return self;
}

#pragma mark - Private

- (void)setDefaultProperty {
    _currentStep = 0;
    _dotCount = 3;
    _animating = NO;
    _duration = .5f;
    _hidesWhenStopped = YES;
    _reverse = NO;
    _repeated = NO;
}

#pragma mark - Private

- (UIColor*)currentBorderColor:(NSInteger)index {
    if (self.currentStep == index) {
        return [UIColor whiteColor];
    } else if (self.currentStep < index) {
        if (!self.isRepeated) {
            return [UIColor clearColor];
        }
        return [UIColor darkGrayColor];
    } else {
        if (self.currentStep - index == 1) {
            return [UIColor grayColor];
        } else {
            return [UIColor darkGrayColor];
        }
    }
}

- (UIColor*)currentInnerColor:(NSInteger)index {
    if (self.currentStep == index) {
        return [UIColor colorWithRed:244.0f/255.0f
                               green:246.0f/255.0f
                                blue:249.0f/255.0f
                               alpha:1];
    } else if (self.currentStep < index) {
        if (!self.isRepeated) {
            return [UIColor clearColor];
        }
        return [UIColor darkGrayColor];
    } else {
        if (self.currentStep - index == 1) {
            return [UIColor lightGrayColor];
        } else if (self.currentStep - index == 2) {
            return [UIColor grayColor];
        } else {
            return [UIColor darkGrayColor];
        }
    }
}

- (CGRect)currentRect:(NSInteger)index {
    if (self.currentStep == index) {
        return CGRectMake(self.bounds.size.width/(_dotCount*2),
                          2,
                          self.bounds.size.width/(_dotCount*2),
                          self.bounds.size.height-4);
    } else if (self.currentStep < index) {
        return CGRectMake(self.bounds.size.width/(_dotCount*2),
                          self.bounds.size.height/5.0,
                          self.bounds.size.width/(_dotCount*2),
                          self.bounds.size.height*3.0/5.0);
    } else {
        if (self.currentStep - index == 1) {
            return CGRectMake(self.bounds.size.width/(_dotCount*2),
                              self.bounds.size.height/10.0,
                              self.bounds.size.width/(_dotCount*2),
                              self.bounds.size.height*4.0/5.0);
        } else {
            return CGRectMake(self.bounds.size.width/(_dotCount*2),
                              self.bounds.size.height/5.0,
                              self.bounds.size.width/(_dotCount*2),
                              self.bounds.size.height*3.0/5.0);
        }
    }
}

- (void)repeatAnimation {
    self.currentStep = ++self.currentStep % (self.dotCount);
    
    if (self.currentStep == 0) {
        self.currentStep = 1;
        self.repeated = YES;
        self.reverse = !self.reverse;
    }
    [self setNeedsDisplay];
}

#pragma mark Drawing

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (self.isReverse) {
        for (long i = self.dotCount - 1; i > 0; i--) {
            [[self currentInnerColor:i] setFill];
            [[self currentBorderColor:i] setStroke];
            
            CGMutablePathRef path = CGPathCreateMutable();
            CGRect rect1 = [self currentRect:i];
            
            CGPathAddRect(path, NULL, rect1);
            CGContextBeginPath(context);
            CGContextAddPath(context, path);
            CGContextSetLineWidth(context, 1);
            CGContextClosePath(context);
            CGContextDrawPath(context, kCGPathFillStroke);
            
            CGContextTranslateCTM(context, (self.bounds.size.width+7)/self.dotCount, 0);
            CGPathRelease(path);
        }
    } else {
        for (int i = 1; i < self.dotCount; i++) {
            [[self currentInnerColor:i] setFill];
            [[self currentBorderColor:i] setStroke];
            
            CGMutablePathRef path = CGPathCreateMutable();
            CGRect rect1 = [self currentRect:i];
            
            CGPathAddRect(path, NULL, rect1);
            CGContextBeginPath(context);
            CGContextAddPath(context, path);
            CGContextSetLineWidth(context, 1);
            CGContextClosePath(context);
            CGContextDrawPath(context, kCGPathFillStroke);
            
            CGContextTranslateCTM(context, (self.bounds.size.width+7)/self.dotCount, 0);
            CGPathRelease(path);
        }
    }
}

#pragma mark - Public

- (void)startAnimating {
    if (self.isAnimating) {
        return;
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.duration/(self.dotCount+2)
                                              target:self
                                            selector:@selector(repeatAnimation)
                                            userInfo:nil
                                             repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    self.animating = YES;
    
    if (self.isHidesWhenStopped) {
        self.hidden = NO;
    }
}

- (void)stopAnimating {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    self.animating = NO;
    
    if (self.isHidesWhenStopped) {
        self.hidden = YES;
    }
}

@end
