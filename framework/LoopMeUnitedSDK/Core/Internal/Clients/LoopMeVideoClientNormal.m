//
//  LoopMeVideoClient.m
//  LoopMeSDK
//
//  Created by Korda Bogdan on 10/20/14.
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
#import "NSString+Encryption.h"


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
@property (nonatomic, assign, getter = isShouldPlay) BOOL shouldPlay;
@property (nonatomic, strong) NSString *layerGravity;

@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, assign) BOOL preloadingForCacheStarted;
@property (nonatomic, assign) BOOL hasPlaybackStarted;

@property (nonatomic, strong) AVAssetResourceLoadingRequest *resourceLoadingRequest;

@property (nonatomic, assign, getter=isDidLoadSent) BOOL didLoadSent;

- (void)setupPlayerWithFileURL: (NSURL *)URL;
- (void)unregisterObservers;
- (void)addTimerForCurrentTime;
- (void)routeChange: (NSNotification*)notification;
- (void)playerItemDidReachEnd: (id)object;

@end

@implementation LoopMeVideoClientNormal

#pragma mark - Properties

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
    [_videoView.layer addSublayer: _playerLayer];
    [self.delegate videoClient: self setupView: _videoView];
    return _videoView;
}

- (id<LoopMeJSCommunicatorProtocol>)JSClient {
    return [self.delegate JSCommunicator];
}

- (BOOL)playerReachedEnd {
    return CMTimeCompare(self.playerItem.duration, self.playerItem.currentTime) == 0;
}

- (void)play {
    if (![self playerReachedEnd]) {
        self.hasPlaybackStarted = YES;
        [self.videoManager cancel];
        self.shouldPlay = YES;
        [self.player play];
    }
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
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    if (_playerItem) {
        [_playerItem removeObserver: self
                         forKeyPath: kLoopMeVideoStatusKey
                            context: VideoControllerStatusObservationContext];
        [_playerItem removeObserver: self
                         forKeyPath: kLoopMeLoadedTimeRangesKey
                            context: VideoControllerStatusObservationContext];
        [nc removeObserver: self name: AVPlayerItemDidPlayToEndTimeNotification object: _playerItem];
        [nc removeObserver: self name: AVPlayerItemFailedToPlayToEndTimeNotification object: _playerItem];
        [nc removeObserver: self name: AVPlayerItemPlaybackStalledNotification object: _playerItem];
    }
    _playerItem = playerItem;
    if (!_playerItem) {
        return;
    }
    [_playerItem addObserver: self
                  forKeyPath: kLoopMeVideoStatusKey
                     options: NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                     context: VideoControllerStatusObservationContext];
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
    [_playerItem addObserver: self
                  forKeyPath: kLoopMeLoadedTimeRangesKey
                     options: NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                     context: VideoControllerStatusObservationContext];
}

- (void)addTimerForCurrentTime {
    CMTime interval = CMTimeMakeWithSeconds(0.1, NSEC_PER_USEC);
    __weak LoopMeVideoClientNormal *selfWeak = self;
    self.playbackTimeObserver = [self.player addPeriodicTimeObserverForInterval: interval
                                                                          queue: NULL
                                                                     usingBlock: ^(CMTime time) {
        float currentTime = (float)CMTimeGetSeconds(time);
        if (currentTime > 0 && selfWeak.isShouldPlay) {
            [selfWeak.JSClient setCurrentTime: currentTime * 1000];
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
    [nc removeObserver: self name: UIApplicationWillEnterForegroundNotification object: nil];
    [nc removeObserver: self name: UIApplicationDidBecomeActiveNotification object: nil];
}

- (void)dealloc {
    [self unregisterObservers];
    [self cancel];
}

- (void)routeChange: (NSNotification *)notification {
    NSInteger routeChangeReason = [[notification.userInfo valueForKey: AVAudioSessionRouteChangeReasonKey] integerValue];
    if (routeChangeReason != AVAudioSessionRouteChangeReasonNewDeviceAvailable &&
        routeChangeReason != AVAudioSessionRouteChangeReasonOldDeviceUnavailable
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
           selector: @selector(didBecomeAcive:)
               name: UIApplicationDidBecomeActiveNotification
             object: nil];
}

- (instancetype)initWithDelegate: (id<LoopMeVideoClientDelegate>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
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


#pragma mark Observers & Timers

- (void)didBecomeAcive: (NSNotification *)notification {
    [self.delegate videoClientDidBecomeActive: self];
}

#pragma mark Player state notification

- (void)playerItemDidReachEnd: (id)object {
    [self.JSClient setVideoState: LoopMeVideoState.completed];
    self.shouldPlay = NO;
    [self.delegate videoClientDidReachEnd: self];
}

- (void)playerItemDidFailedToPlayToEndTime: (id)object {
    [self pause];
    [self.JSClient setVideoState: LoopMeVideoState.paused];
}

- (void)observeValueForKeyPath: (NSString *)keyPath
                      ofObject: (id)object
                        change: (NSDictionary *)change
                       context: (void *)context {
    if (object != self.playerItem) {
        return;
    }
    if (![keyPath isEqualToString: kLoopMeVideoStatusKey]) {
        return;
    }
    if (self.playerItem.status == AVPlayerItemStatusFailed) {
        NSMutableDictionary *infoDictionary = [self.delegate.adConfiguration toDictionary];
        infoDictionary[kErrorInfoClass] = @"LoopMeVideoClientNormal";
        infoDictionary[kErrorInfoUrl] = self.videoURL;
        [LoopMeErrorEventSender sendError: LoopMeEventErrorTypeBadAsset
                             errorMessage: [NSString stringWithFormat: @"Video player could not init file"]
                                     info: infoDictionary];
        [self.JSClient setVideoState: LoopMeVideoState.broken];
    }
    if (self.playerItem.status == AVPlayerItemStatusReadyToPlay) {
        [self.JSClient setVideoState: LoopMeVideoState.ready];
        [self.JSClient setDuration: CMTimeGetSeconds(self.player.currentItem.asset.duration) * 1000];
    }
}

#pragma mark - Public

- (void)playVideo: (NSURL *)URL {
    if (!URL) {
        [self.delegate videoClient: self didFailToLoadVideoWithError: [LoopMeError errorForStatusCode: LoopMeErrorCodeURLResolve]];
        return;
    }
    // ImageContext used to avoid CGErrors
    // http://stackoverflow.com/questions/13203336/iphone-mpmovieplayerviewcontroller-cgcontext-errors/14669166#14669166
    AVPlayer *player = [AVPlayer playerWithURL: URL];
    UIGraphicsBeginImageContext(CGSizeMake(1,1));
    AVPlayerViewController *playerViewController = [AVPlayerViewController new];
    playerViewController.player = player;
    UIGraphicsEndImageContext();
    [[self.delegate viewControllerForPresentation] presentViewController: playerViewController
                                                                animated: YES
                                                              completion: ^{
        [playerViewController.player play];
    }];
}

- (void)adjustViewToFrame: (CGRect)frame {
    self.videoView.frame = frame;
    if (!self.playerLayer) {
        return;
    }
    self.playerLayer.frame = frame;
    if (self.layerGravity) {
        self.playerLayer.videoGravity = self.layerGravity;
        self.layerGravity = nil;
        return;
    }
    CGRect videoRect = [self.playerLayer videoRect];
    CGFloat k = 100;
    CGFloat vw = videoRect.size.width;
    CGFloat vh = videoRect.size.height;
    CGFloat pw = self.playerLayer.bounds.size.width;
    CGFloat ph = self.playerLayer.bounds.size.height;
    if (vw == pw || vh == ph) {
        k = (vw == pw) ? (vh * 100 / ph) : (vw * 100 / pw);
    }
    if ((100 - floorf(k)) <= kResizeOffset) {
        [self.playerLayer setVideoGravity: AVLayerVideoGravityResize];
    }
}

- (void)cancel {
    [self.videoManager cancel];
    [self.playerLayer removeFromSuperlayer];
    [self.videoView removeFromSuperview];
    self.shouldPlay = NO;
}

- (void)moveView {
    [self.delegate videoClient: self setupView: self.videoView];
}

#pragma mark - LoopMeJSVideoTransportProtocol

- (void)videoManager: (LoopMeVideoManager *)videoManager didFailLoadWithError: (NSError *)error {
    [self.JSClient setVideoState: LoopMeVideoState.broken];
    [self.delegate videoClient: self didFailToLoadVideoWithError: error];
}

- (void)videoManager:(LoopMeVideoManager *)videoManager didLoadVideo:(NSURL *)videoURL {
    if (!self.hasPlaybackStarted) {
        [self setupPlayerWithFileURL:videoURL];
    }
}

- (void)loadWithURL: (NSURL *)URL {
    self.videoURL = URL;
    self.videoManager = [[LoopMeVideoManager alloc] initWithUniqueName:[self.adConfigurationObject.appKey lm_MD5]
                                                              delegate:self];
    if ([LoopMeGlobalSettings sharedInstance].doNotLoadVideoWithoutWiFi &&
        [[LoopMeReachability reachabilityForLocalWiFi] connectionType] != LoopMeConnectionTypeWiFi
    ) {
        [self.JSClient setVideoState: LoopMeVideoState.broken];
        [self.delegate videoClient: self didFailToLoadVideoWithError: [LoopMeError errorForStatusCode: LoopMeErrorCodeCanNotLoadVideo]];
        return;
    }
    if (!self.isDidLoadSent) {
        [self setupPlayerWithFileURL: [self.videoManager cacheVideoWith: URL]];
        self.didLoadSent = YES;
    }
    if ([self.player.currentItem.asset isKindOfClass: [AVURLAsset class]]) {
        [self.JSClient setVideoState: LoopMeVideoState.ready];
        [self.JSClient setDuration: CMTimeGetSeconds(self.player.currentItem.asset.duration) * 1000];
        return;
    }
}

- (void)setMute: (BOOL)mute {
    self.player.volume = (mute) ? 0.0f : 1.0f;
}

- (void)seekToTime: (double)time {
    if (time >= 0) {
        [self.player seekToTime: CMTimeMake(time, 1000) toleranceBefore: kCMTimeZero toleranceAfter: kCMTimePositiveInfinity];
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

- (void)pause {
    self.shouldPlay = NO;
    [self.player pause];
}

- (void)resume {
    self.shouldPlay = YES;
    [self.player play];
}

- (void)pauseOnTime: (double)time {
    [self seekToTime: time];
    self.shouldPlay = NO;
    [self.JSClient setVideoState: LoopMeVideoState.paused];
    [self.player pause];
}

- (void)setGravity: (NSString *)gravity {
    self.layerGravity = gravity;
    if (self.playerLayer) {
        self.playerLayer.videoGravity = gravity;
    }
}

#pragma mark - LoopMeDraweblePixelsProtocol

- (CVPixelBufferRef)retrievePixelBufferToDraw {
    return [self.videoOutput copyPixelBufferForItemTime: [self.playerItem currentTime] itemTimeForDisplay: nil];
}

#pragma mark - LoopMeVideoManagerDelegate

- (LoopMeAdConfiguration *)adConfigurationObject {
    return self.delegate.adConfiguration;
}

- (void)willAppear { }

@end
