//
//  LoopMeVASTPlayerUIView.m
//  LoopMeSDK
//
//  Copyright © 2016 LoopMe. All rights reserved.
//

#import "LoopMeVASTPlayerUIView.h"
#import "LoopMeSDK.h"
#import "LoopMeResources.h"


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

- (void)dealloc {
    
}

- (instancetype)initWithDelegate:(id<LoopMePlayerUIViewDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview) {
        [self initUI];
    } else {
        [self.endCard removeFromSuperview];
    }
}

- (void)initUI {
    UITapGestureRecognizer *tapVideo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoTapped)];
    [self addGestureRecognizer:tapVideo];
    
    self.muteButton = [[UIButton alloc] init];
    
    NSData *muteImageData = [[NSData alloc] initWithBase64EncodedString:kLoopMeResourceBase64Mute options:0];
    UIImage *muteImage = [UIImage imageWithData:muteImageData];
    [self.muteButton setImage:muteImage forState:UIControlStateSelected];
    NSData *unmuteImageData = [[NSData alloc] initWithBase64EncodedString:kLoopMeResourceBase64Unmute options:0];
    UIImage *unmuteImage = [UIImage imageWithData:unmuteImageData];
    [self.muteButton setImage:unmuteImage forState:UIControlStateNormal];
    [self.muteButton addTarget:self action:@selector(mute:) forControlEvents:UIControlEventTouchUpInside];
    self.muteButton.selected = NO;
    self.muteButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.muteButton];
    
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    self.progressView.trackTintColor = [UIColor lightGrayColor];
    self.progressView.progressTintColor = [UIColor colorWithRed:0 green:142/255.f blue:239/255.f alpha:1];
    self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
    self.progressView.layer.masksToBounds = YES;
    self.progressView.layer.cornerRadius = self.progressView.bounds.size.height / 2;
    [self addSubview:self.progressView];
    
    self.countDownLabel = [[UILabel alloc] init];
    self.countDownLabel.textColor = [UIColor lightGrayColor];
    self.countDownLabel.font = [UIFont systemFontOfSize:12];
    self.countDownLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.countDownLabel];
    
    
    self.endCardBackground = [[UIImageView alloc] init];
    self.endCardBackground.translatesAutoresizingMaskIntoConstraints = NO;
    self.endCardBackground.backgroundColor = [UIColor blackColor];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        UIImage *bluredImage = [self blurredImageWithImage:self.endCardImage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.endCardBackground.image = bluredImage;
        });
    });
    self.endCardBackground.contentMode = UIViewContentModeScaleAspectFill;
    self.endCardBackground.clipsToBounds = YES;
    [self addSubview:self.endCardBackground];
    
    self.endCard = [[UIImageView alloc] init];
    self.endCard.translatesAutoresizingMaskIntoConstraints = NO;
    self.endCard.backgroundColor = [UIColor clearColor];
    self.endCard.image = self.endCardImage;
    self.endCard.contentMode = UIViewContentModeScaleToFill;
    [self addSubview:self.endCard];
    
    self.replayButton = [[UIButton alloc] init];
    NSData *replayImageData = [[NSData alloc] initWithBase64EncodedString:kLoopMeResourceBase64Replay options:0];
    UIImage *replayImage = [UIImage imageWithData:replayImageData];
    [self.replayButton setImage:replayImage forState:UIControlStateNormal];
    [self.replayButton addTarget:self action:@selector(replay:) forControlEvents:UIControlEventTouchUpInside];
    self.replayButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.replayButton];
    
    self.skipButton = [[UIButton alloc] init];
    NSData *skipImageData = [[NSData alloc] initWithBase64EncodedString:kLoopMeResourceBase64Skip options:0];
    UIImage *skipImage = [UIImage imageWithData:skipImageData];
    [self.skipButton setImage:skipImage forState:UIControlStateNormal];
    [self.skipButton addTarget:self action:@selector(skip:) forControlEvents:UIControlEventTouchUpInside];
    self.skipButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.skipButton];
    
    self.closeButton = [[UIButton alloc] init];
    NSData *closeImageData = [[NSData alloc] initWithBase64EncodedString:kLoopMeResourceBase64Close options:0];
    UIImage *closeImage = [UIImage imageWithData:closeImageData];
    [self.closeButton setImage:closeImage forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    self.closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.closeButton.hidden = NO;
    [self addSubview:self.closeButton];
    
    NSDictionary *views = @{@"progress" : self.progressView, @"mute" : self.muteButton, @"countdown" : self.countDownLabel, @"close" : self.closeButton, @"replay" : self.replayButton, @"skipped" : self.skipButton,  @"endCard" : self.endCard, @"endCardBackground" : self.endCardBackground};
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[mute(50)]" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[mute(50)]" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[replay(50)]" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[replay(50)]" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[close(50)]" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[close(50)]-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[skipped(50)]" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[skipped(50)]-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[countdown]-4-[progress]-0-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[progress]-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[countdown]" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[endCard]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[endCard]|" options:0 metrics:nil views:views]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[endCardBackground]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[endCardBackground]|" options:0 metrics:nil views:views]];
}

- (void)setVideoCurrentTime:(CGFloat)currentTime {

    if (self.skipOffset.value <= currentTime) {
        [self showSkipButton];
    }
    
    self.progressView.progress = currentTime / self.videoDuration;
    
    int secondsToEnd = self.videoDuration - currentTime + 1;
    NSUInteger minutes = floor(secondsToEnd % 3600 / 60);
    NSUInteger seconds = floor(secondsToEnd % 3600 % 60);
    NSString *time = [NSString stringWithFormat:@"%02ld:%02ld", (unsigned long)minutes, (unsigned long)seconds];
    self.countDownLabel.text = time;
    [self.countDownLabel sizeToFit];
}

- (void)setVideoDuration:(CGFloat)duration {
    _videoDuration = duration;
}

- (void)setMute:(BOOL)mute {
    self.muteButton.selected = mute;
    [self.delegate uiViewMuted:mute];
}

- (void)showEndCard:(BOOL)show {
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

#pragma mark - Private

- (UIImage *)blurredImageWithImage:(UIImage *)sourceImage {
    //  Create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:sourceImage.CGImage];
    
    //  Setting up Gaussian Blur
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:20.0f] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    /*  CIGaussianBlur has a tendency to shrink the image a little, this ensures it matches
     *  up exactly to the bounds of our original image */
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    UIImage *retVal = [UIImage imageWithCGImage:cgImage];
    
    if (cgImage) {
        CGImageRelease(cgImage);
    }
    
    return retVal;
}

- (void)showSkipButton {
    if (!self.endCard.hidden) {
        return;
    }
    self.skipButton.hidden = NO;
}

- (void)mute:(UIButton *)muteButton {
    [self setMute:!muteButton.selected];
}

- (void)close:(UIButton *)closeButton {
    [self.delegate uiViewClose];
}

- (void)replay:(UIButton *)replayButton {
    [self.delegate uiViewReplay];
    self.skipButton.hidden = NO;
}

- (void)skip:(UIButton *)skipButton {
    self.skipButton.hidden = YES;
    [self.delegate uiViewSkip];
}

- (void)expandCollapse:(UIButton *)expandButton {
    [self.delegate uiViewExpand:!expandButton.selected];
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
