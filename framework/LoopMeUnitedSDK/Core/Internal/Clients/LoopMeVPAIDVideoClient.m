//
//  LoopMeVPAIDVideoClient.m
//  LoopMeSDK
//
//  Copyright (c) 2016 LoopMe. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <LoopMeUnitedSDK/LoopMeUnitedSDK-Swift.h>

#import "LoopMeVPAIDVideoClient.h"
#import "LoopMeVPAIDError.h"
#import "LoopMeVideoManager.h"
#import "LoopMeLogging.h"

#import "LoopMeSDK.h"
#import "LoopMeReachability.h"
#import "LoopMeGlobalSettings.h"
#import "LoopMeErrorEventSender.h"
#import "LoopMeDefinitions.h"
#import "LoopMeAdView.h"
#import "NSString+Encryption.h"

@class LoopMeAdConfiguration;

static void *VPAIDvideoControllerStatusObservationContext = &VPAIDvideoControllerStatusObservationContext;
NSString * const kLoopMeVPAIDVideoStatusKey = @"status";
NSString * const kLoopMeVPAIDLoadedTimeRangesKey = @"loadedTimeRanges";

const NSInteger kResizeOffsetVPAID = 11;

@interface LoopMeVPAIDVideoClient ()
<
    LoopMeVideoManagerDelegate,
    LoopMePlayerUIViewDelegate,
    AVPlayerItemOutputPullDelegate,
    AVAssetResourceLoaderDelegate
>
@property (nonatomic, weak) id<LoopMeVPAIDVideoClientDelegate> delegate;

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVAudioSession *audioSession;

@property (nonatomic, readwrite, strong) LoopMeVASTPlayerUIView *vastUIView;

@property (nonatomic, strong) UIView *videoView;

@property (nonatomic, strong) id playbackTimeObserver;
@property (nonatomic, strong) LoopMeVideoManager *videoManager;
@property (nonatomic, assign, getter = isShouldPlay) BOOL shouldPlay;
@property (nonatomic, assign, getter = isSkipped) BOOL skipped;
@property (nonatomic, strong) NSString *layerGravity;

@property (nonatomic, weak) LoopMeOMIDVideoEventsWrapper *omidVideoEvents;
@property (nonatomic, assign) BOOL isDidReachEndSent;

@property (nonatomic, strong) NSLayoutConstraint *topVideoUIConstraint;
@property (nonatomic, strong) NSLayoutConstraint *bottomVideoUIConstraint;
@property (nonatomic, strong) NSLayoutConstraint *leftVideoUIConstraint;
@property (nonatomic, strong) NSLayoutConstraint *rightVideoUIConstraint;

@property (nonatomic, assign, getter=isDidLoadSent) BOOL didLoadSent;
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, assign) BOOL playStarted;

- (void)setupPlayerWithFileURL: (NSURL *)URL;
- (void)unregisterObservers;
- (void)addTimerForCurrentTime;
- (void)routeChange: (NSNotification*)notification;
- (void)playerItemDidReachEnd: (id)object;

@end

@implementation LoopMeVPAIDVideoClient

#pragma mark - Properties

- (UIView *)vastUIView {
    if (!_vastUIView) {
        _vastUIView = [[LoopMeVASTPlayerUIView alloc] initWithDelegate: self];
        _vastUIView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _vastUIView;
}

- (UIView *)videoView {
    if (_videoView != nil) {
        return _videoView;
    }
    if (!self.player) {
        return nil;
    }
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer: self.player];
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    _playerLayer.needsDisplayOnBoundsChange = YES;

    _videoView = [[UIView alloc] init];
    [self.delegate videoClient: self setupView: _videoView];
    [_videoView.layer addSublayer: _playerLayer];
    [_videoView addSubview: self.vastUIView];
    
    self.leftVideoUIConstraint = [self.vastUIView.leadingAnchor constraintEqualToAnchor: _videoView.leadingAnchor];
    self.leftVideoUIConstraint.active = YES;
    
    self.rightVideoUIConstraint = [self.vastUIView.trailingAnchor constraintEqualToAnchor: _videoView.trailingAnchor];
    self.rightVideoUIConstraint.active = YES;
    
    self.topVideoUIConstraint = [self.vastUIView.topAnchor constraintEqualToAnchor: _videoView.topAnchor];
    self.topVideoUIConstraint.active = YES;
    
    self.bottomVideoUIConstraint = [self.vastUIView.bottomAnchor constraintEqualToAnchor: _videoView.bottomAnchor];
    self.bottomVideoUIConstraint.active = YES;
    return _videoView;
}

- (LoopMeOMIDVideoEventsWrapper *)omidVideoEvents {
    return [self.delegate respondsToSelector: @selector(omidVideoEvents)] ?
        [self.delegate performSelector: @selector(omidVideoEvents)] : nil;
}

- (void)playerItemDidReachEnd: (id)object {
    if (!self.isDidReachEndSent) {
        self.isDidReachEndSent = YES;
        self.shouldPlay = NO;
        [self.eventSender trackEvent: LoopMeVASTEventTypeLinearComplete];
        [self.delegate videoClientDidReachEnd: self];
        [self.omidVideoEvents complete];
    }
    if ([self.vastUIView hasEndCard]) {
        [self showEndCard];
    } else {
        [self.delegate videoClientShouldCloseAd: self];
    }
}

- (void)playerItemDidFailedToPlayToEndTime: (id)object {
    [self pause];
}

- (void)playbackStalled: (NSNotification *)n {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self play];
    });
}

- (void)setPlayerItem: (AVPlayerItem *)playerItem {
    if (_playerItem == playerItem) {
        return;
    }
    self.isDidReachEndSent = NO;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    if (_playerItem) {
        [_playerItem removeObserver: self
                         forKeyPath: kLoopMeVPAIDVideoStatusKey
                            context: VPAIDvideoControllerStatusObservationContext];
        [_playerItem removeObserver: self
                         forKeyPath: kLoopMeVPAIDLoadedTimeRangesKey
                            context: VPAIDvideoControllerStatusObservationContext];
        [nc removeObserver: self name: AVPlayerItemDidPlayToEndTimeNotification object: _playerItem];
        [nc removeObserver: self name: AVPlayerItemFailedToPlayToEndTimeNotification object: _playerItem];
        [nc removeObserver: self name: AVPlayerItemPlaybackStalledNotification object: _playerItem];
    }
    _playerItem = playerItem;
    if (!_playerItem) {
        return;
    }
    [_playerItem addObserver: self
                  forKeyPath: kLoopMeVPAIDVideoStatusKey
                     options: NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                     context: VPAIDvideoControllerStatusObservationContext];
    [_playerItem addObserver: self
                  forKeyPath: kLoopMeVPAIDLoadedTimeRangesKey
                     options: NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                     context: VPAIDvideoControllerStatusObservationContext];
    [nc addObserver: self
           selector: @selector(playerItemDidReachEnd:)
               name: AVPlayerItemDidPlayToEndTimeNotification
             object: _playerItem];
    [nc addObserver: self
           selector: @selector(playerItemDidFailedToPlayToEndTime:)
               name: AVPlayerItemFailedToPlayToEndTimeNotification
             object: _playerItem];
    [nc addObserver: self
           selector: @selector(playbackStalled:)
               name: AVPlayerItemPlaybackStalledNotification
             object: _playerItem];
    
}

- (void)addTimerForCurrentTime {
    CMTime interval = CMTimeMakeWithSeconds(0.1, NSEC_PER_USEC);
    __weak LoopMeVPAIDVideoClient *selfWeak = self;
    self.playbackTimeObserver =
    [self.player addPeriodicTimeObserverForInterval: interval
                                              queue: NULL
                                         usingBlock: ^(CMTime time) {
         float currentTime = (float)CMTimeGetSeconds(time);
         double percent = currentTime / CMTimeGetSeconds(selfWeak.playerItem.duration);
         [selfWeak.delegate currentTime: currentTime percent: percent];
         if (currentTime > 0 && selfWeak.isShouldPlay) {
             [selfWeak.vastUIView setVideoCurrentTime: currentTime];
         }
     }];
}

- (void)setPlayer: (AVPlayer *)player {
    if (_player == player) {
        return;
    }
    [self.playerLayer removeFromSuperlayer];
    [self.videoView removeFromSuperview];
    self.playerLayer = nil;
    if (_player) {
        [_player removeTimeObserver: self.playbackTimeObserver];
        self.playbackTimeObserver = nil;
    }
    _player = player;
    if (_player) {
        [self addTimerForCurrentTime];
        [self videoView];
        self.shouldPlay = NO;
    }
}

#pragma mark - Life Cycle

- (void)unregisterObservers {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver: self name: AVAudioSessionRouteChangeNotification object: nil];
    [nc removeObserver: self name: UIApplicationDidBecomeActiveNotification object: nil];
    [nc removeObserver: self name: UIApplicationDidEnterBackgroundNotification object: nil];
}

- (void)cancel {
    [self.playerLayer removeFromSuperlayer];
    [_videoView removeFromSuperview];
    [_vastUIView removeFromSuperview];
    self.player = nil;
    self.playerItem = nil;
    self.videoView = nil;
    self.playerLayer = nil;
    self.shouldPlay = NO;
}

- (void)dealloc {
    if (![NSThread isMainThread]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self unregisterObservers];
            [self cancel];
        });
    } else {
        [self unregisterObservers];
        [self cancel];
    }
}

- (void)routeChange: (NSNotification*)notification {
    NSInteger routeChangeReason = [[notification.userInfo valueForKey: AVAudioSessionRouteChangeReasonKey] integerValue];
    if (routeChangeReason == AVAudioSessionRouteChangeReasonNewDeviceAvailable ||
        routeChangeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable
    ) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.isShouldPlay) {
                [self.player play];
            }
        });
    }
}

- (void)registerObservers {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver: self
           selector: @selector(routeChange:)
               name: AVAudioSessionRouteChangeNotification
             object: nil];
    [nc addObserver: self
           selector: @selector(didBecomeActive:)
               name: UIApplicationDidBecomeActiveNotification
             object: nil];
    [nc addObserver: self
           selector: @selector(didEnterBackground:)
               name: UIApplicationDidEnterBackgroundNotification
             object: nil];
}

- (instancetype)initWithDelegate: (id<LoopMeVPAIDVideoClientDelegate>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
        _audioSession = [AVAudioSession sharedInstance];
        [self registerObservers];
    }
    return self;
}

#pragma mark - Private

- (void)setupPlayerWithFileURL: (NSURL *)URL {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.playerItem = [AVPlayerItem playerItemWithURL: URL];
        if (self.player != nil) {
            [self.player replaceCurrentItemWithPlayerItem:self.playerItem];
        } else {
            self.player = [AVPlayer playerWithPlayerItem: self.playerItem];
        }
    });
}

- (void)showEndCard {
    [self.vastUIView showEndCard: YES];
    [self.eventSender trackEvent: LoopMeVASTEventTypeCompanionCreativeView];
}

#pragma mark Observers & Timers

- (void)didBecomeActive: (NSNotification*)notification {
    [self.delegate videoClientDidBecomeActive: self];
}

- (void)didEnterBackground: (NSNotification*)notification {
    [self.omidVideoEvents pause];
    [self.player pause];
}

#pragma mark Player state notification

- (void)observeValueForKeyPath: (NSString *)keyPath
                      ofObject: (id)object
                        change: (NSDictionary *)change
                       context: (void *)context {
    if (object != self.playerItem ) {
        return;
    }
    if (![keyPath isEqualToString: kLoopMeVPAIDVideoStatusKey]) {
        return;
    }
    if (self.playerItem.status == AVPlayerItemStatusFailed) {
        NSMutableDictionary *infoDictionary = [self.delegate.adConfigurationObject toDictionary];
        infoDictionary[kErrorInfoClass] = @"LoopMeVPAIDVideoClient";
        infoDictionary[kErrorInfoUrl] = self.videoURL;
        [LoopMeErrorEventSender sendError: LoopMeEventErrorTypeBadAsset
                             errorMessage: @"Video player could not init file"
                                     info: infoDictionary];
        [self uiViewClose];
        [self.delegate videoClient: self didFailToLoadVideoWithError: [LoopMeVPAIDError errorForStatusCode: LoopMeVPAIDErrorCodeMediaDisplay]];
    }
    if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
        [self.delegate videoClientDidLoadVideo: self];
        [self.vastUIView setVideoDuration: CMTimeGetSeconds(self.player.currentItem.asset.duration)];
    }
}

#pragma mark - Public

- (void)adjustViewToFrame: (CGRect)frame {
    self.videoView.frame = frame;
    if (SYSTEM_VERSION_LESS_THAN(@"13.0")) {
        NSBundle *resourcesBundle = [LoopMeSDK resourcesBundle];
        self.vastUIView.frame = frame;
        MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame: frame];
        volumeView.showsVolumeSlider = YES;
        volumeView.showsRouteButton = NO;
        
        UIImage *thumb = [UIImage imageNamed: @"thumb" inBundle: resourcesBundle compatibleWithTraitCollection: nil];
        [volumeView setVolumeThumbImage: thumb forState: UIControlStateNormal];
        
        UIImage *max = [UIImage imageNamed: @"maximumVolume" inBundle: resourcesBundle compatibleWithTraitCollection: nil];
        [volumeView setMaximumVolumeSliderImage: max forState: UIControlStateNormal];
        
        UIImage *min = [UIImage imageNamed: @"minimumVolume" inBundle: resourcesBundle compatibleWithTraitCollection: nil];
        [volumeView setMinimumVolumeSliderImage: min forState: UIControlStateNormal];
        
        volumeView.alpha = 1;
    }

    if (self.playerLayer) {
        self.playerLayer.frame = frame;
        if (self.layerGravity) {
            self.playerLayer.videoGravity = self.layerGravity;
            self.layerGravity = nil;
            return;
        }
    }
    if ([[self.delegate performSelector: @selector(delegate)] isKindOfClass: [LoopMeAdView class]]) {
        CGRect videoRect = self.playerLayer.videoRect;
        CGRect bounds = self.playerLayer.bounds;

        self.leftVideoUIConstraint.constant = videoRect.origin.x;
        self.rightVideoUIConstraint.constant = bounds.size.width - videoRect.size.width - videoRect.origin.x;
        self.topVideoUIConstraint.constant = videoRect.origin.y;
        self.bottomVideoUIConstraint.constant = -(bounds.size.height - videoRect.size.height - videoRect.origin.y);
    }
}

- (void)moveView {
    [self.delegate videoClient: self setupView: self.videoView];
}

- (void)willAppear {
    [self.delegate videoClient: self setupView: self.videoView];
    if (self.skipped) {
        return;
    }
    LoopMeVastSkipOffset *skipOffset = [self.delegate skipOffset];
    double skipOffsetTime = skipOffset.type == LoopMeTimeOffsetTypeSeconds ?
           skipOffset.value : CMTimeGetSeconds(self.playerItem.duration) * skipOffset.value / 100;
    [self.vastUIView setSkipOffset: CMTimeMake(skipOffsetTime, 1)];
    [self play];
    [self.omidVideoEvents startWithDuration: CMTimeGetSeconds(self.playerItem.duration)
                          videoPlayerVolume: self.player.volume];
}

- (BOOL)playerReachedEnd {
    return self.playerItem.duration.value == self.playerItem.currentTime.value;
}

#pragma mark - LoopMeJSVideoTransportProtocol

- (void)videoManager: (LoopMeVideoManager *)videoManager didFailLoadWithError: (NSError *)error {
    [self.delegate videoClient: self didFailToLoadVideoWithError: error];
}

- (void)videoManager:(LoopMeVideoManager *)videoManager didLoadVideo:(NSURL *)videoURL {
    [self setupPlayerWithFileURL:videoURL];
}

- (void)loadWithURL: (NSURL *)URL {
    self.videoURL = URL;
    self.videoManager = [[LoopMeVideoManager alloc] initWithUniqueName:[self.adConfigurationObject.appKey lm_MD5]
                                                              delegate:self];
    if ([LoopMeGlobalSettings sharedInstance].doNotLoadVideoWithoutWiFi &&
        [[LoopMeReachability reachabilityForLocalWiFi] connectionType] != LoopMeConnectionTypeWiFi
    ) {
        [self.delegate videoClient: self didFailToLoadVideoWithError: [LoopMeVPAIDError errorForStatusCode: LoopMeVPAIDErrorCodeUndefined]];
        return;
    }
    if (!self.isDidLoadSent) {
        [self setupPlayerWithFileURL: [self.videoManager cacheVideoWith: URL]];
        self.didLoadSent = YES;
    }
}

- (void)resume {
    [self.omidVideoEvents resume];
    [self play];
    [self.eventSender trackEvent: LoopMeVASTEventTypeLinearResume];
}

- (void)play {
    self.playStarted = true;
    [self.player play];
    if (self.shouldPlay) {
        [self.vastUIView showEndCard: NO];
    }
    [self.eventSender trackEvent: LoopMeVASTEventTypeLinearStart];
    self.shouldPlay = YES;
}

- (void)pause {
    self.shouldPlay = NO;
    [self.player pause];
    [self.omidVideoEvents pause];
}

- (void)setGravity: (NSString *)gravity {
    self.layerGravity = gravity;
    if (self.playerLayer) {
        self.playerLayer.videoGravity = gravity;
    }
}

#pragma mark - LoopMeVideoUIViewDelegate

- (void)setMute: (BOOL)mute {
    self.player.volume = mute ? 0.0f : 1.0f;
    [self.omidVideoEvents volumeChangeTo: self.player.volume];
}

- (void)uiViewMuted: (BOOL)mute {
    [self.eventSender trackEvent: mute ? LoopMeVASTEventTypeLinearMute : LoopMeVASTEventTypeLinearUnmute];
    [self setMute: mute];
}

- (void)uiViewClose {
    [_audioSession setActive: NO error: nil];
    [self.delegate videoClientShouldCloseAd: self];
}

- (void)playFromTime: (double)time {
    //if time is negative, dont seek. Hack for setVisibleNoJS property in LoopMeAdDisplaycontroller.
    if (time >= 0) {
        [self.player seekToTime: CMTimeMake(time, 1000) toleranceBefore: kCMTimeZero toleranceAfter: kCMTimePositiveInfinity];
    }
    [self play];
}

- (void)uiViewReplay {
    self.shouldPlay = YES;
    [self playFromTime: 0];
}

- (void)skip {
    self.shouldPlay = NO;
    self.skipped = YES;
    [self.eventSender trackEvent:LoopMeVASTEventTypeLinearSkip];
    [self pause];
    [self.omidVideoEvents skipped];
    if ([self.vastUIView hasEndCard]) {
        [self showEndCard];
    } else {
        [self.delegate videoClientShouldCloseAd: self];
    }
}

- (void)uiViewSkip {
    [self skip];
}

- (void)uiViewEndCardTapped {
    [self.delegate videoClientDidEndCardTap];
}

- (void)uiViewVideoTapped {
    [self.delegate videoClientDidVideoTap];
    [self.omidVideoEvents adUserInteractionWithType: OMIDInteractionTypeClick];
}

- (void)uiViewExpand: (BOOL)expand {
    [self.delegate videoClientDidExpandTap: expand];
}

#pragma mark - LoopMeVideoManagerDelegate

- (LoopMeAdConfiguration *)adConfigurationObject {
    return self.delegate.adConfigurationObject;
}

@end
