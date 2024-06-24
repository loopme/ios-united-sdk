//
//  LoopMeVideoClient.m
//  LoopMeSDK
//
//  Created by Korda Bogdan on 10/20/14.
//
//
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import <LoopMeUnitedSDK/LoopMeUnitedSDK-Swift.h>


#import "LoopMeVideoClientNormal.h"
#import "LoopMeDefinitions.h"
#import "LoopMeJSCommunicatorProtocol.h"
#import "LoopMeError.h"
#import "LoopMeVideoManager.h"
#import "LoopMeLogging.h"

#import "LoopMeReachability.h"
#import "LoopMeGlobalSettings.h"
#import "LoopMeErrorEventSender.h"
#import "LoopMeAdWebView.h"

const struct LoopMeVideoStateStruct LoopMeVideoState = {
    .ready = @"READY",
    .completed = @"COMPLETE",
    .playing = @"PLAYING",
    .paused = @"PAUSED",
    .broken = @"BROKEN"
};

static void *VideoControllerStatusObservationContext = &VideoControllerStatusObservationContext;
NSString * const kLoopMeVideoStatusKey = @"status";
NSString * const kLoopMeLoadedTimeRangesKey = @"loadedTimeRanges";

const NSInteger kResizeOffset = 11;
const CGFloat kOneFrameDuration = 0.03;

@interface LoopMeVideoClientNormal ()
<
LoopMeVideoManagerDelegate,
AVPlayerItemOutputPullDelegate,
AVAssetResourceLoaderDelegate
>
@property (nonatomic, weak) id<LoopMeVideoClientDelegate> delegate;
@property (nonatomic, weak) id<LoopMeJSCommunicatorProtocol> JSClient;

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, strong) AVPlayerItemVideoOutput *videoOutput;
@property (nonatomic) dispatch_queue_t myVideoOutputQueue;
@property (nonatomic, strong) UIView *videoView;

@property (nonatomic, strong) NSTimer *loadingVideoTimer;
@property (nonatomic, strong) id playbackTimeObserver;
@property (nonatomic, strong) LoopMeVideoManager *videoManager;
@property (nonatomic, strong) NSString *videoPath;
@property (nonatomic, assign, getter = isShouldPlay) BOOL shouldPlay;
@property (nonatomic, assign, getter = isStatusSent) BOOL statusSent;
@property (nonatomic, strong) NSString *layerGravity;

@property (nonatomic, strong) NSDate *loadingVideoStartDate;
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, assign) CMTime preloadedDuration;
@property (nonatomic, assign) BOOL preloadingForCacheStarted;

@property (nonatomic, strong) AVAssetResourceLoadingRequest *resourceLoadingRequest;

- (NSURL *)currentAssetURLForPlayer:(AVPlayer *)player;
- (void)setupPlayerWithFileURL:(NSURL *)URL;
- (BOOL)playerHasBufferedURL:(NSURL *)URL;
- (void)unregisterObservers;
- (void)addTimerForCurrentTime;
- (void)routeChange:(NSNotification*)notification;
- (void)willEnterForeground:(NSNotification*)notification;
- (void)playerItemDidReachEnd:(id)object;

@end

@implementation LoopMeVideoClientNormal

#pragma mark - Properties

- (UIView *)videoView {
    if (_videoView == nil) {
        if (!self.player) {
            return nil;
        }
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        [_playerLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
        _playerLayer.needsDisplayOnBoundsChange = YES;
        
        UIView *videoView = [[UIView alloc] init];
        [videoView.layer addSublayer:_playerLayer];
        _videoView = videoView;
        
        [self.delegate videoClient:self setupView:_videoView];
    }
    return _videoView;
}

- (id<LoopMeJSCommunicatorProtocol>)JSClient {
    return [self.delegate JSCommunicator];
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    if (_playerItem != playerItem) {
        if (_playerItem) {
            [_playerItem removeObserver:self forKeyPath:kLoopMeVideoStatusKey context:VideoControllerStatusObservationContext];
            [_playerItem removeObserver:self forKeyPath:kLoopMeLoadedTimeRangesKey context:VideoControllerStatusObservationContext];
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
            [_playerItem addObserver:self forKeyPath:kLoopMeVideoStatusKey options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:VideoControllerStatusObservationContext];
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
                          forKeyPath:kLoopMeLoadedTimeRangesKey
                             options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                             context:VideoControllerStatusObservationContext];
            
        }
    }
}

- (void)playbackStalled:(NSNotification *)n {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self play];
    });
}

- (void)setPlayer:(AVPlayer *)player {
    if(_player != player) {
        self.statusSent = NO;
        [self.playerLayer removeFromSuperlayer];
        [self.videoView removeFromSuperview];
        self.playerLayer = nil;
        
        if (_player) {
            [_player removeTimeObserver:self.playbackTimeObserver];
        }
        _player = player;
        
        if (_player) {
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

- (instancetype)initWithDelegate:(id<LoopMeVideoClientDelegate>)delegate {
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

- (BOOL)playerReachedEnd {
    CMTime duration = self.playerItem.duration;
    CMTime currentTime = self.playerItem.currentTime;
    return (duration.value == currentTime.value) ? YES : NO;
}

#pragma mark Observers & Timers

- (void)registerObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(routeChange:)
                                                 name:AVAudioSessionRouteChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeAcive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}

- (void)unregisterObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVAudioSessionRouteChangeNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
}

- (void)addTimerForCurrentTime {
    CMTime interval = CMTimeMakeWithSeconds(0.1, NSEC_PER_USEC);
    __weak LoopMeVideoClientNormal *selfWeak = self;
    self.playbackTimeObserver =
    [self.player addPeriodicTimeObserverForInterval: interval
                                              queue: NULL
                                         usingBlock: ^(CMTime time) {
        float currentTime = (float)CMTimeGetSeconds(time);
        if (currentTime > 0 && selfWeak.isShouldPlay) {
            [selfWeak.JSClient setCurrentTime:currentTime*1000];
        }
    }];
}

- (void)routeChange:(NSNotification *)notification {
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.isShouldPlay) {
                    [self.player play];
                }
            });
            break;
    }
}

- (void)willEnterForeground:(NSNotification *)notification {
    if (!self.isStatusSent && self.player) {
        [self setupPlayerWithFileURL:[self currentAssetURLForPlayer:self.player]];
    }
}

- (void)didBecomeAcive:(NSNotification *)notification {
    [self.delegate videoClientDidBecomeActive:self];
}

#pragma mark Player state notification

- (void)playerItemDidReachEnd:(id)object {
    [self.JSClient setVideoState:LoopMeVideoState.completed];
    self.shouldPlay = NO;
    [self.delegate videoClientDidReachEnd:self];
}

- (void)playerItemDidFailedToPlayToEndTime:(id)object {
    [self pause];
    [self.JSClient setVideoState:LoopMeVideoState.paused];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    if (object == self.playerItem) {
        if ([keyPath isEqualToString:kLoopMeVideoStatusKey]) {
            if (self.playerItem.status == AVPlayerItemStatusFailed) {
                if ([self.delegate.adConfiguration preload25]) {
                    [self.videoManager failedInitPlayer: self.videoURL];
                } else {
                    NSMutableDictionary *infoDictionary = [self.delegate.adConfiguration toDictionary];
                    [infoDictionary setObject:@"LoopMeVideoClientNormal" forKey: @"class"];
                    [self.JSClient setVideoState:LoopMeVideoState.broken];
                    [LoopMeErrorEventSender sendError: LoopMeEventErrorTypeBadAsset
                                         errorMessage: [NSString stringWithFormat: @"Video player could not init file: %@", self.videoURL]
                                                 info:infoDictionary];
                    self.statusSent = YES;
                }
            } else if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
                if (([self.videoManager hasCachedURL:self.videoURL] && !self.isStatusSent) ) {
                    [self.JSClient setVideoState:LoopMeVideoState.ready];
                    [self.JSClient setDuration:CMTimeGetSeconds(self.player.currentItem.asset.duration)*1000];
                    self.statusSent = YES;
                }
            }
        } else if ([keyPath isEqualToString:kLoopMeLoadedTimeRangesKey]) {
            if (self.delegate.adConfiguration.preload25) {
                
                if (self.preloadedDuration.value == 0) {
                    return;
                }
                
                CMTimeRange loadedTimeRanges = [[[object loadedTimeRanges] objectAtIndex:0] CMTimeRangeValue];
                long long loadedLenght = (loadedTimeRanges.start.value + loadedTimeRanges.duration.value);
                BOOL isFullyPreloaded =  loadedLenght == self.preloadedDuration.value;
                
                if (isFullyPreloaded && ![self.videoManager hasCachedURL:self.videoURL] && !self.preloadingForCacheStarted) {
                    self.preloadingForCacheStarted = YES;
                    [self.videoManager loadVideoWithURL:self.videoURL];
                } else if ((loadedLenght >= self.preloadedDuration.value / 4) && !self.statusSent) {
                    if (![self.videoManager hasCachedURL:self.videoURL]) {
                        [self.JSClient setVideoState:LoopMeVideoState.ready];
                        [self.JSClient setDuration:CMTimeGetSeconds(self.preloadedDuration)*1000];
                        self.statusSent = YES;
                    }
                }
            }
        }
    }
}

#pragma mark - Public

- (void)playVideo:(NSURL *)URL {
    if (!URL) {
        [self.delegate videoClient:self didFailToLoadVideoWithError:[LoopMeError errorForStatusCode:LoopMeErrorCodeURLResolve]];
        return;
    }
    
    
    // ImageContext used to avoid CGErrors
    // http://stackoverflow.com/questions/13203336/iphone-mpmovieplayerviewcontroller-cgcontext-errors/14669166#14669166
    AVPlayer *player = [AVPlayer playerWithURL:URL];
    UIGraphicsBeginImageContext(CGSizeMake(1,1));
    AVPlayerViewController *playerViewController = [AVPlayerViewController new];
    playerViewController.player = player;
    UIGraphicsEndImageContext();
    
    [[self.delegate viewControllerForPresentation] presentViewController:playerViewController animated:YES completion:^{
        [playerViewController.player play];
    }];
}

- (void)adjustViewToFrame:(CGRect)frame {
    self.videoView.frame = frame;
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
        
        if ((100 - floorf(k)) <= kResizeOffset) {
            [self.playerLayer setVideoGravity:AVLayerVideoGravityResize];
        }
    }
}

- (void)cancel {
    [self.videoManager cancel];
    [self.playerLayer removeFromSuperlayer];
    [self.videoView removeFromSuperview];
    self.shouldPlay = NO;
}

- (void)moveView {
    [self.delegate videoClient:self setupView:self.videoView];
}

#pragma mark - LoopMeJSVideoTransportProtocol

- (void)loadWithURL:(NSURL *)URL {
    self.videoPath = [NSString stringWithFormat:@"%li.mp4", URL.hash];
    self.videoManager = [[LoopMeVideoManager alloc] initWithVideoPath:self.videoPath delegate:self];
    if ([self playerHasBufferedURL:URL]) {
        [self.JSClient setVideoState:LoopMeVideoState.ready];
        [self.JSClient setDuration:CMTimeGetSeconds(self.player.currentItem.asset.duration)*1000];
    } else if ([self.videoManager hasCachedURL:URL]) {
        [self setupPlayerWithFileURL:[self.videoManager videoFileURL]];
    } else {
        if ([LoopMeGlobalSettings sharedInstance].doNotLoadVideoWithoutWiFi && [[LoopMeReachability reachabilityForLocalWiFi] connectionType] != LoopMeConnectionTypeWiFi) {
            [self videoManager:self.videoManager didFailLoadWithError:[LoopMeError errorForStatusCode:LoopMeErrorCodeCanNotLoadVideo]];
            return;
        }
        
        self.loadingVideoStartDate = [NSDate date];
        self.videoURL = URL;
        if (self.delegate.adConfiguration.preload25) {
            AVURLAsset *asset = [AVURLAsset assetWithURL:URL];
            self.preloadedDuration = kCMTimeZero;
            __weak LoopMeVideoClientNormal *safeSelf = self;
            [asset loadValuesAsynchronouslyForKeys:@[@"duration"] completionHandler:^{
                safeSelf.preloadedDuration = asset.duration;
            }];
            self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
            self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
        } else {
            [self.videoManager loadVideoWithURL:URL];
        }
    }
}

- (void)setMute:(BOOL)mute {
    self.player.volume = (mute) ? 0.0f : 1.0f;
}

- (void)seekToTime:(double)time {
    if (time >= 0) {
        CMTime timeStruct = CMTimeMake(time, 1000);
        [self.player seekToTime:timeStruct
                toleranceBefore:kCMTimeZero
                 toleranceAfter:kCMTimePositiveInfinity];
    }
}

- (void)playFromTime: (double)time {
    //if time is negative, dont seek. Hack for setVisibleNoJS property in LoopMeAdDisplaycontroller.
    if (time >= 0) {
        [self seekToTime: time];
    }
    self.shouldPlay = YES;
    [self.JSClient setVideoState: LoopMeVideoState.playing];
    [self.player play];
}

- (void)play {
    if (![self playerReachedEnd]) {
        self.shouldPlay = YES;
        [self.player play];
    }
}

- (void)pause {
    self.shouldPlay = NO;
    [self.player pause];
}

- (void)resume {
    self.shouldPlay = YES;
    [self.player play];
}

- (void)pauseOnTime:(double)time {
    [self seekToTime:time];
    self.shouldPlay = NO;
    [self.JSClient setVideoState:LoopMeVideoState.paused];
    [self.player pause];
}

- (void)setGravity:(NSString *)gravity {
    self.layerGravity = gravity;
    if (self.playerLayer) {
        self.playerLayer.videoGravity = gravity;
    }
}

#pragma mark - LoopMeDraweblePixelsProtocol

- (CVPixelBufferRef)retrievePixelBufferToDraw {
    CVPixelBufferRef pixelBuffer = [self.videoOutput copyPixelBufferForItemTime:[self.playerItem currentTime] itemTimeForDisplay:nil];
    
    return pixelBuffer;
}


#pragma mark - LoopMeVideoManagerDelegate

- (void)videoManager:(LoopMeVideoManager *)videoManager didLoadVideo:(NSURL *)videoURL {
    if (!self.delegate.adConfiguration.preload25) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setupPlayerWithFileURL:videoURL];
        });
    }
}

- (void)videoManager:(LoopMeVideoManager *)videoManager didFailLoadWithError:(NSError *)error {
    if (!self.delegate.adConfiguration.preload25) {
        [self.JSClient setVideoState:LoopMeVideoState.broken];
        [self.delegate videoClient:self didFailToLoadVideoWithError:error];
    }
}

- (LoopMeAdConfiguration *)adConfiguration {
    return self.delegate.adConfiguration;
}

- (void)willAppear {
}

@end
