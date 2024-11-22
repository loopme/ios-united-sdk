//
//  LoopMePlayerUIView.h
//  LoopMeSDK
//
//  Copyright © 2016 LoopMe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>

@protocol LoopMePlayerUIViewDelegate;
@interface LoopMeVASTPlayerUIView : UIView

- (instancetype)initWithDelegate:(id<LoopMePlayerUIViewDelegate>)delegate;

@property (nonatomic, weak) id<LoopMePlayerUIViewDelegate> delegate;
@property (nonatomic, strong) UIImage *endCardImage;

- (void)setVideoDuration:(CGFloat)duration;
- (void)setVideoCurrentTime:(CGFloat)currentTime;
- (void)showEndCard:(BOOL)show;
- (void)setSkipOffset:(CMTime)skipOffset;
- (void)updateEndCard: (UIImage *)image;
- (BOOL)hasEndCard;
@end

@protocol LoopMePlayerUIViewDelegate <NSObject>

- (void)uiViewMuted:(BOOL)mute;
- (void)uiViewClose;
- (void)uiViewReplay;
- (void)uiViewSkip;
- (void)uiViewEndCardTapped;
- (void)uiViewVideoTapped;
- (void)uiViewExpand:(BOOL)expand;
@end
