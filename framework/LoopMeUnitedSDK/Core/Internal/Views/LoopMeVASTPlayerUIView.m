//
//  LoopMeVASTPlayerUIView.m
//  LoopMeSDK
//
//  Copyright © 2016 LoopMe. All rights reserved.
//

#import "LoopMeVASTPlayerUIView.h"
#import "LoopMeSDK.h"

@interface LoopMeVASTPlayerUIView ()

@property (nonatomic, strong) UIImageView *endCard;
@property (nonatomic, strong) UIImageView *endCardBackground;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIButton *replayButton;
@property (nonatomic, strong) UIButton *skipButton;
@property (nonatomic, strong) UIButton *muteButton;

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UILabel *countDownLabel;
@property (nonatomic, assign) CGFloat videoDuration;

@property (nonatomic, assign) CMTime skipOffset;

@end

@implementation LoopMeVASTPlayerUIView

- (void)dealloc { }

- (instancetype)initWithDelegate: (id<LoopMePlayerUIViewDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)willMoveToSuperview: (UIView *)newSuperview {
    [super willMoveToSuperview: newSuperview];
    if (newSuperview) {
        [self initUI];
    } else {
        [self.endCard removeFromSuperview];
    }
}

- (void)initUI {
    [self addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget: self action: @selector(videoTapped)]];
    
    NSBundle *resourcesBundle = [LoopMeSDK resourcesBundle];
    self.muteButton = [[UIButton alloc] init];
    [self.muteButton setImage: [UIImage imageNamed: @"loopmemute" inBundle: resourcesBundle compatibleWithTraitCollection: nil]
                     forState: UIControlStateSelected];
    [self.muteButton setImage: [UIImage imageNamed: @"loopmeunmute" inBundle: resourcesBundle compatibleWithTraitCollection: nil]
                     forState: UIControlStateNormal];
    [self.muteButton addTarget: self action: @selector(mute:) forControlEvents: UIControlEventTouchUpInside];
    self.muteButton.selected = NO;
    self.muteButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview: self.muteButton];
    
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle: UIProgressViewStyleBar];
    self.progressView.trackTintColor = [UIColor lightGrayColor];
    self.progressView.progressTintColor = [UIColor colorWithRed: 0 green: 142/255.f blue: 239/255.f alpha: 1];
    self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
    self.progressView.layer.masksToBounds = YES;
    self.progressView.layer.cornerRadius = self.progressView.bounds.size.height / 2;
    [self addSubview: self.progressView];
    
    self.countDownLabel = [[UILabel alloc] init];
    self.countDownLabel.textColor = [UIColor lightGrayColor];
    self.countDownLabel.font = [UIFont systemFontOfSize: 12];
    self.countDownLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview: self.countDownLabel];
    
    self.endCardBackground = [[UIImageView alloc] init];
    self.endCardBackground.translatesAutoresizingMaskIntoConstraints = NO;
    self.endCardBackground.backgroundColor = [UIColor blackColor];
    self.endCardBackground.contentMode = UIViewContentModeScaleAspectFill;
    self.endCardBackground.clipsToBounds = YES;
    [self addSubview: self.endCardBackground];
    
    self.endCard = [[UIImageView alloc] init];
    self.endCard.translatesAutoresizingMaskIntoConstraints = NO;
    self.endCard.backgroundColor = [UIColor clearColor];
    self.endCard.image = self.endCardImage;
    self.endCard.contentMode = UIViewContentModeScaleToFill;
    [self addSubview: self.endCard];
    
    self.replayButton = [[UIButton alloc] init];
    [self.replayButton setImage: [UIImage imageNamed: @"loopmereplay"
                                            inBundle: resourcesBundle
                       compatibleWithTraitCollection: nil]
                       forState: UIControlStateNormal];
    [self.replayButton addTarget: self action: @selector(replay:) forControlEvents: UIControlEventTouchUpInside];
    self.replayButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview: self.replayButton];
    
    self.skipButton = [[UIButton alloc] init];
    [self.skipButton setImage: [UIImage imageNamed: @"loopmeskip" inBundle: resourcesBundle compatibleWithTraitCollection: nil]
                     forState: UIControlStateNormal];
    [self.skipButton addTarget: self action: @selector(skip:) forControlEvents: UIControlEventTouchUpInside];
    self.skipButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview: self.skipButton];
    
    self.closeButton = [[UIButton alloc] init];
    [self.closeButton setImage: [UIImage imageNamed: @"loopmeclose" inBundle: resourcesBundle compatibleWithTraitCollection: nil]
                      forState: UIControlStateNormal];
    [self.closeButton addTarget: self action: @selector(close:) forControlEvents: UIControlEventTouchUpInside];
    self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.closeButton.hidden = NO;
    [self addSubview: self.closeButton];
    
    NSDictionary *views = @{
        @"progress": self.progressView,
        @"mute": self.muteButton,
        @"countdown": self.countDownLabel,
        @"close": self.closeButton,
        @"replay": self.replayButton,
        @"skipped": self.skipButton,
        @"endCard": self.endCard,
        @"endCardBackground": self.endCardBackground
    };
    
    NSArray *formats = @[
        @"V:|-[mute(50)]",
        @"|-[mute(50)]",
        @"V:|-[replay(50)]",
        @"|-[replay(50)]",
        @"V:|-[close(50)]",
        @"[close(50)]-|",
        @"V:|-[skipped(50)]",
        @"[skipped(50)]-|",
        @"V:[countdown]-4-[progress]-0-|",
        @"|-[progress]-|",
        @"|-[countdown]",
        @"V:|[endCard]|",
        @"H:|[endCard]|",
        @"V:|[endCardBackground]|",
        @"H:|[endCardBackground]|"
    ];
    for (NSString *format in formats) {
        [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: format options: 0 metrics: nil views: views]];
    }
}

- (void)setVideoCurrentTime: (CGFloat)currentTime {
    if (self.skipOffset.value <= currentTime) {
        [self showSkipButton];
    }
    self.progressView.progress = currentTime / self.videoDuration;
    int secondsToEnd = self.videoDuration - currentTime + 1;
    NSUInteger minutes = floor(secondsToEnd % 3600 / 60);
    NSUInteger seconds = floor(secondsToEnd % 3600 % 60);
    NSString *time = [NSString stringWithFormat: @"%02ld:%02ld", (unsigned long)minutes, (unsigned long)seconds];
    self.countDownLabel.text = time;
    [self.countDownLabel sizeToFit];
}

- (void)setVideoDuration: (CGFloat)duration {
    _videoDuration = duration;
}

- (void)setMute: (BOOL)mute {
    self.muteButton.selected = mute;
    [self.delegate uiViewMuted: mute];
}

- (void)showEndCard: (BOOL)show {
    if (!show && self.endCard.hidden) {
        return;
    }
    self.endCard.hidden = !show;
    self.endCardBackground.hidden = !show;
    self.closeButton.hidden = !show;
    self.replayButton.hidden = !show;
    self.progressView.hidden = show;
    self.muteButton.hidden = show;
    self.countDownLabel.hidden = show;
    self.skipButton.hidden = YES;
}

- (void)updateEndCard: (UIImage *)image {
    self.endCard.image = image;
}

- (BOOL)hasEndCard {
    return  self.endCard.image;
}

#pragma mark - Private

- (void)showSkipButton {
    if (!self.endCard.hidden) {
        return;
    }
    self.skipButton.hidden = NO;
}

- (void)mute: (UIButton *)muteButton {
    [self setMute:!muteButton.selected];
}

- (void)close: (UIButton *)closeButton {
    [self.delegate uiViewClose];
}

- (void)replay: (UIButton *)replayButton {
    [self.delegate uiViewReplay];
    self.skipButton.hidden = NO;
}

- (void)skip: (UIButton *)skipButton {
    self.skipButton.hidden = YES;
    [self.delegate uiViewSkip];
}

- (void)expandCollapse: (UIButton *)expandButton {
    [self.delegate uiViewExpand: !expandButton.selected];
    expandButton.selected = !expandButton.selected;
}

- (void)videoTapped {
    if (self.endCard.hidden) {
        [self.delegate uiViewVideoTapped];
    } else {
        [self.delegate uiViewEndCardTapped];
    }
}

@end
