//
//  LoopMeVPAIDVideoClient.m
//  LoopMeSDK
//
//  Copyright (c) 2016 LoopMe. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <LOOMoatMobileAppKit/LOOMoatMobileAppKit.h>

#import "LoopMeVPAIDVideoClient.h"
#import "LoopMeVPAIDError.h"
#import "LoopMeVideoManager.h"
#import "LoopMeLogging.h"
#import "LoopMeVASTEventTracker.h"

#import "LoopMeReachability.h"
#import "LoopMeGlobalSettings.h"
#import "LoopMeAdConfiguration.h"
#import "LoopMeErrorEventSender.h"
#import "LoopMeDefinitions.h"
#import "LoopMeAdView.h"
#import "LoopMeIASWrapper.h"
#import "NSString+Encryption.h"

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
@property (nonatomic, readwrite, strong) LoopMeVASTPlayerUIView *vastUIView;

@property (nonatomic, strong) UIView *videoView;

@property (nonatomic, strong) id playbackTimeObserver;
@property (nonatomic, strong) LoopMeVideoManager *videoManager;
@property (nonatomic, strong) NSString *videoPath;
@property (nonatomic, assign, getter = isShouldPlay) BOOL shouldPlay;
@property (nonatomic, assign, getter = isSkipped) BOOL skipped;
@property (nonatomic, strong) NSString *layerGravity;

@property (nonatomic, strong) NSDate *loadingVideoStartDate;
@property (nonatomic, strong) NSURL *videoURL;

@property (nonatomic, strong) LOOMoatVideoTracker *moatVideoTracker;

- (NSURL *)currentAssetURLForPlayer:(AVPlayer *)player;
- (void)setupPlayerWithFileURL:(NSURL *)URL;
- (BOOL)playerHasBufferedURL:(NSURL *)URL;
- (void)unregisterObservers;
- (void)addTimerForCurrentTime;
- (void)routeChange:(NSNotification*)notification;
- (void)playerItemDidReachEnd:(id)object;

@end

@implementation LoopMeVPAIDVideoClient

#pragma mark - Properties

- (UIView *)vastUIView {
    if (!_vastUIView) {
        _vastUIView = [[LoopMeVASTPlayerUIView alloc] initWithDelegate:self];
    }
    return _vastUIView;
}

- (UIView *)videoView {
    if (_videoView == nil) {
        if (!self.player) {
            return nil;
        }
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        [_playerLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
        _playerLayer.needsDisplayOnBoundsChange = YES;
            
        UIView *videoView = [[UIView alloc] init];
        _videoView = videoView;
         [self.delegate videoClient:self setupView:_videoView];
        [_videoView.layer addSublayer:_playerLayer];
        [_videoView addSubview:self.vastUIView];
    }
    return _videoView;
}

- (LoopMeIASWrapper *)iasWrapper {
    if ([self.delegate respondsToSelector:@selector(iasWarpper)]) {
        return [self.delegate performSelector:@selector(iasWarpper)];
    }
    
    return nil;
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    if (_playerItem != playerItem) {
        if (_playerItem) {
            [_playerItem removeObserver:self forKeyPath:kLoopMeVPAIDVideoStatusKey context:VPAIDvideoControllerStatusObservationContext];
            [_playerItem removeObserver:self forKeyPath:kLoopMeVPAIDLoadedTimeRangesKey context:VPAIDvideoControllerStatusObservationContext];
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:AVPlayerItemDidPlayToEndTimeNotification
                                                          object:_playerItem];
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:AVPlayerItemFailedToPlayToEndTimeNotification
                                                          object:_playerItem];
            
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemPlaybackStalledNotification object:_playerItem];
        }
        _playerItem = playerItem;
        if (_playerItem) {
            [_playerItem addObserver:self forKeyPath:kLoopMeVPAIDVideoStatusKey options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:VPAIDvideoControllerStatusObservationContext];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playerItemDidReachEnd:)
                                                         name:AVPlayerItemDidPlayToEndTimeNotification
                                                       object:_playerItem];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(playerItemDidFailedToPlayToEndTime:)
                                                         name:AVPlayerItemFailedToPlayToEndTimeNotification
                                                       object:_playerItem];
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStalled:) name:AVPlayerItemPlaybackStalledNotification object:_playerItem];
            
            [_playerItem addObserver:self
                             forKeyPath:kLoopMeVPAIDLoadedTimeRangesKey
                                options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                                context:VPAIDvideoControllerStatusObservationContext];

        }
    }
}

- (void)playbackStalled:(NSNotification *)n {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self play];
    });
}

- (void)setPlayer:(AVPlayer *)player {
    if (_player != player) {
        
        [self.playerLayer removeFromSuperlayer];
        [self.videoView removeFromSuperview];
        self.playerLayer = nil;
        
        if (_player) {
            [_player removeTimeObserver:self.playbackTimeObserver];
        }
        _player = player;
        
        if (_player) {
            [self.playbackTimeObserver invalidate];
            
            [self addTimerForCurrentTime];
            [self videoView];
            self.shouldPlay = NO;
        }
    }
}

#pragma mark - Life Cycle

- (void)dealloc {
    [self unregisterObservers];
    [self cancel];
}

- (instancetype)initWithDelegate:(id<LoopMeVPAIDVideoClientDelegate>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
        [self registerObservers];
    }
    return self;
}

#pragma mark - Private

- (NSURL *)currentAssetURLForPlayer:(AVPlayer *)player {
    AVAsset *currentPlayerAsset = player.currentItem.asset;
    if (![currentPlayerAsset isKindOfClass:AVURLAsset.class]) {
        return nil;
    }
    return [(AVURLAsset *)currentPlayerAsset URL];
}

- (void)setupPlayerWithFileURL:(NSURL *)URL {
    self.playerItem = [AVPlayerItem playerItemWithURL:URL];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
}

- (BOOL)playerHasBufferedURL:(NSURL *)URL {
    if (!self.videoPath) {
        return NO;
    }
    return [[self currentAssetURLForPlayer:self.player].absoluteString hasSuffix:self.videoPath];
}

- (void)showEndCard {
    [self.vastUIView showEndCard:YES];
    [self.eventSender trackEvent:LoopMeVASTEventTypeCompanionCreativeView];
}

#pragma mark Observers & Timers

- (void)registerObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(routeChange:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
}

- (void)unregisterObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVAudioSessionRouteChangeNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
}

- (void)addTimerForCurrentTime {
    CMTime interval = CMTimeMakeWithSeconds(0.1, NSEC_PER_USEC);
    __weak LoopMeVPAIDVideoClient *selfWeak = self;
    self.playbackTimeObserver =
    [self.player addPeriodicTimeObserverForInterval:interval
                                              queue:NULL
                                         usingBlock:^(CMTime time) {
                                             float currentTime = (float)CMTimeGetSeconds(time);
                                             double percent = currentTime / CMTimeGetSeconds(selfWeak.playerItem.duration);
                                             if (percent >= 0.25 && percent < 0.5) {
                                                 [selfWeak.eventSender trackEvent:LoopMeVASTEventTypeLinearFirstQuartile];
                                                 [selfWeak.iasWrapper recordAdVideoFirstQuartileEvent];
                                             } else if (percent >= 0.5 && percent < 0.75) {
                                                 [selfWeak.eventSender trackEvent:LoopMeVASTEventTypeLinearMidpoint];
                                                 [selfWeak.iasWrapper recordAdVideoMidpointEvent];
                                             } else if (percent >= 0.75) {
                                                 [selfWeak.eventSender trackEvent:LoopMeVASTEventTypeLinearThirdQuartile];
                                                 [selfWeak.iasWrapper recordAdVideoThirdQuartileEvent];
                                             }
                                             [selfWeak.eventSender setCurrentTime:currentTime];
                                             if (currentTime > 0 && selfWeak.isShouldPlay) {
                                                 [selfWeak.vastUIView setVideoCurrentTime:currentTime];
                                             }
                                         }];
}

- (void)routeChange:(NSNotification*)notification {
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.isShouldPlay) {
                    [self.player play];
                    [self.iasWrapper recordAdPlayingEvent];
                }
            });
            break;
    }
}

- (void)didBecomeActive:(NSNotification*)notification {
    [self.delegate videoClientDidBecomeActive:self];
}

- (void)didEnterBackground:(NSNotification*)notification {
    [self.player pause];
}
#pragma mark Player state notification

- (void)playerItemDidReachEnd:(id)object {
    self.shouldPlay = NO;
    [self.eventSender trackEvent:LoopMeVASTEventTypeLinearComplete];
    [self.delegate videoClientDidReachEnd:self];
    
    if ([self.vastUIView endCardImage]) {
        [self showEndCard];
    } else {
        [self.delegate videoClientShouldCloseAd:self];
    }
}

- (void)playerItemDidFailedToPlayToEndTime:(id)object {
    [self pause];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    if (object == self.playerItem ) {
        if ([keyPath isEqualToString:kLoopMeVPAIDVideoStatusKey]) {
            if (self.playerItem.status == AVPlayerItemStatusFailed) {
                [LoopMeErrorEventSender sendError:LoopMeEventErrorTypeBadAsset errorMessage:@"Video player could not init file" appkey:self.appKey];
                [self.delegate videoClient:self didFailToLoadVideoWithError:[LoopMeVPAIDError errorForStatusCode:LoopMeVPAIDErrorCodeMediaDisplay]];
            } else if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
                if ([self.videoManager hasCachedURL:self.videoURL]) {
                    [self.delegate videoClientDidLoadVideo:self];
                    [self.vastUIView setVideoDuration:CMTimeGetSeconds(self.player.currentItem.asset.duration)];
                }
            }
        }
    }
}

#pragma mark - Public

- (void)adjustViewToFrame:(CGRect)frame {
    self.videoView.frame = frame;
    
    self.vastUIView.frame = frame;

    if (self.playerLayer) {
        self.playerLayer.frame = frame;
        if (self.layerGravity) {
            self.playerLayer.videoGravity = self.layerGravity;
            self.layerGravity = nil;
            return;
        }
        
        CGRect videoRect = [self.playerLayer videoRect];
        CGFloat k = 100;
        if (videoRect.size.width == self.playerLayer.bounds.size.width) {
            k = videoRect.size.height * 100 / self.playerLayer.bounds.size.height;
        } else if (videoRect.size.height == self.playerLayer.bounds.size.height) {
            k = videoRect.size.width * 100 / self.playerLayer.bounds.size.width;
        }
        
        if ((100 - floorf(k)) <= kResizeOffsetVPAID) {
            [self.playerLayer setVideoGravity:AVLayerVideoGravityResize];
        }
    }
    
    if  ([[self.delegate performSelector:@selector(delegate)] isKindOfClass:[LoopMeAdView class]]) {
        self.vastUIView.frame = self.playerLayer.videoRect;
    }
}

- (void)cancel {
    if ([self.delegate.adConfiguration useTracking:LoopMeTrackerName.moat]) {
        [self.moatVideoTracker stopTracking];
    }

    [self.videoManager cancel];
    [self.playerLayer removeFromSuperlayer];
    [_videoView removeFromSuperview];
    [_vastUIView removeFromSuperview];
    self.player = nil;
    self.playerItem = nil;
    self.videoView = nil;
    self.playerLayer = nil;
    self.shouldPlay = NO;
}

- (void)moveView {
    [self.delegate videoClient:self setupView:self.videoView];
}

- (void)willAppear {
    [self.delegate videoClient:self setupView:self.videoView];
    if (!self.skipped) {
        [self play];
        
        LoopMeSkipOffset skipOffset = [self.delegate skipOffset];
        CMTime skipOffsetTime;
        if (skipOffset.type == LoopMeSkipOffsetTypeSec) {
            skipOffsetTime = CMTimeMake(skipOffset.value, 1);
        } else {
            int sec = CMTimeGetSeconds(self.playerItem.duration) * skipOffset.value / 100;
            skipOffsetTime = CMTimeMake(sec, 1);
        }
        [self.vastUIView setSkipOffset:skipOffsetTime];
    }
}

- (BOOL)playerReachedEnd {
    CMTime duration = self.playerItem.duration;
    CMTime currentTime = self.playerItem.currentTime;
    return (duration.value == currentTime.value) ? YES : NO;
}

#pragma mark - LoopMeJSVideoTransportProtocol

- (void)loadWithURL:(NSURL *)URL {
    
    if ([_delegate.adConfiguration useTracking:LoopMeTrackerName.moat] && !_delegate.adConfiguration.isV360) {
        _moatVideoTracker = [LOOMoatVideoTracker trackerWithPartnerCode:LOOPME_MOAT_PARTNER_CODE];
    }
    
    self.videoURL = URL;
    
    self.videoPath = [NSString stringWithFormat:@"%@.mp4", [URL.absoluteString lm_MD5]];
    self.videoManager = [[LoopMeVideoManager alloc] initWithVideoPath:self.videoPath delegate:self];
    if ([self playerHasBufferedURL:URL]) {
        [self.vastUIView setVideoDuration:CMTimeGetSeconds(self.player.currentItem.asset.duration)];
    } else if ([self.videoManager hasCachedURL:URL]) {
        [self setupPlayerWithFileURL:[self.videoManager videoFileURL]];
    } else {
        if ([LoopMeGlobalSettings sharedInstance].doNotLoadVideoWithoutWiFi && [[LoopMeReachability reachabilityForLocalWiFi] connectionType] != LoopMeConnectionTypeWiFi) {
            [self videoManager:self.videoManager didFailLoadWithError:[LoopMeVPAIDError errorForStatusCode:LoopMeVPAIDErrorCodeUndefined]];
            return;
        }
        
        self.loadingVideoStartDate = [NSDate date];
        [self.videoManager loadVideoWithURL:URL];
    }
}

- (void)setMute:(BOOL)mute {
    self.player.volume = (mute) ? 0.0f : 1.0f;
    [self.iasWrapper recordAdVolumeChangeEvent:self.player.volume];
}

- (void)seekToTime:(double)time {
    if (time >= 0) {
        CMTime timeStruct = CMTimeMake(time, 1000);
        [self.player seekToTime:timeStruct
                toleranceBefore:kCMTimeZero
                 toleranceAfter:kCMTimePositiveInfinity];
    }
}

- (void)playFromTime:(double)time {
    //if time is negative, dont seek. Hack for setVisibleNoJS property in LoopMeAdDisplaycontroller.    
    if (time >= 0) {
        [self seekToTime:time];
    }

    [self play];
}

- (void)play {
    self.shouldPlay = YES;
    [self.player play];
    [self.vastUIView showEndCard:NO];
    [self.eventSender trackEvent:LoopMeVASTEventTypeLinearStart];
    [self.iasWrapper recordAdPlayingEvent];
}

- (void)pause {
    self.shouldPlay = NO;
    [self.player pause];
    
    [self.iasWrapper recordAdPausedEvent];
}

- (void)skip {
    self.shouldPlay = NO;
    self.skipped = YES;
    [self.eventSender trackEvent:LoopMeVASTEventTypeLinearSkip];
    [self pause];
    if ([self.vastUIView endCardImage]) {
        [self showEndCard];
    } else {
        [self.delegate videoClientShouldCloseAd:self];
    }
}

- (void)setGravity:(NSString *)gravity {
    self.layerGravity = gravity;
    if (self.playerLayer) {
        self.playerLayer.videoGravity = gravity;
    }
}

#pragma mark - LoopMeVideoUIViewDelegate

- (void)uiViewMuted:(BOOL)mute {
    [self.eventSender trackEvent: mute ? LoopMeVASTEventTypeLinearMute : LoopMeVASTEventTypeLinearUnmute];
    [self setMute:mute];
}

- (void)uiViewClose {
    [self.delegate videoClientShouldCloseAd:self];
}

- (void)uiViewReplay {
    [self playFromTime:0];
}

- (void)uiViewSkip {
    [self skip];
}

- (void)uiViewEndCardTapped {
    [self.delegate videoClientDidEndCardTap];
}

- (void)uiViewVideoTapped {
    [self.delegate videoClientDidVideoTap];
}

- (void)uiViewExpand:(BOOL)expand {
    [self.delegate videoClientDidExpandTap:expand];
}

#pragma mark - LoopMeVideoManagerDelegate

- (void)videoManager:(LoopMeVideoManager *)videoManager didLoadVideo:(NSURL *)videoURL {
    NSTimeInterval secondsFromVideoLoadStart = [self.loadingVideoStartDate timeIntervalSinceNow];
    [LoopMeLoggingSender sharedInstance].videoLoadingTimeInterval = fabs(secondsFromVideoLoadStart);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setupPlayerWithFileURL:videoURL];
    });
}

- (void)videoManager:(LoopMeVideoManager *)videoManager didFailLoadWithError:(NSError *)error {

    [self.delegate videoClient:self didFailToLoadVideoWithError:error];
}

- (NSString *)appKey {
    return self.delegate.adConfiguration.appKey;
}

@end
