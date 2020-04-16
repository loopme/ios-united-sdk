//
//  OMIDVideoEvents.h
//  AppVerificationLibrary
//
//  Created by Daria Sukhonosova on 30/06/2017.
//

#import <Foundation/Foundation.h>
#import "OMIDAdSession.h"
#import "OMIDVASTProperties.h"
#import "OMIDMediaEvents.h"

/**
 * DEPRECATED. This provides a complete list of native video events supported by OMID.
 * Using this event API assumes the video player is fully responsible for communicating all video
 * events at the appropriate times. Only one video events implementation can be associated with the
 * ad session and any attempt to create multiple instances will result in an error.
 *
 * Warning:
 *  * This class will be fully removed in OM SDK 1.3.4 or later. Use `OMIDMediaEvents` instead.
 * @see OMIDVideoEvents
 */
__deprecated_msg("Use OMIDMediaEvents") @interface OMIDLoopmeVideoEvents : NSObject

/**
 * DEPRECATED. Initializes video events instance for the associated ad session.
 * Any attempt to create a video events instance will fail if the supplied ad session has already
 * started.
 *
 * @param session The ad session associated with the ad events.
 * @return A new video events instance. Returns nil if the supplied ad session is nil or if a video
 * events instance has already been registered with the ad session or if a video events instance has
 * been created after the ad session has started.
 * @see OMIDAdSession
 *
 * Warning:
 *  * This class will be fully removed in OM SDK 1.3.4 or later. Use `OMIDMediaEvents` instead.
 * @see OMIDMediaEvents
 */
- (nullable instancetype)initWithAdSession:(nonnull OMIDLoopmeAdSession *)session
                                     error:(NSError *_Nullable *_Nullable)error
    __deprecated_msg("Use -[OMIDMediaEvents initWithAdSession:error:]");

/**
 * DEPRECATED. Notifies all video listeners that video content has been loaded and ready to start
 * playing.
 *
 * @param vastProperties The parameters containing static information about the video placement.
 *
 * Warning:
 *  * This class will be fully removed in OM SDK 1.3.4 or later. Use
 *    `-[OMIDAdEvents loadedWithVastProperties:error:]` instead.
 * @see OMIDAdEvents
 */
- (void)loadedWithVastProperties:(nonnull OMIDLoopmeVASTProperties *)vastProperties
    __deprecated_msg("Use -[OMIDAdEvents loadedWithVastProperties:error:]");

/**
 * DEPRECATED. Notifies all video listeners that video content has started playing.
 *
 * @param duration The duration of the selected video media (in seconds).
 * @param videoPlayerVolume The volume from the native video player with a range between 0 and 1.
 *
 * Warning:
 *  * This class will be fully removed in OM SDK 1.3.4 or later. Use `OMIDMediaEvents` instead.
 * @see OMIDMediaEvents
 */
- (void)startWithDuration:(CGFloat)duration
        videoPlayerVolume:(CGFloat)videoPlayerVolume
    __deprecated_msg("Use -[OMIDMediaEvents startWithDuration:videoPlayerVolume:]");

/**
 * DEPRECATED. Notifies all video listeners that video playback has reached the first quartile.
 *
 * Warning:
 *  * This class will be fully removed in OM SDK 1.3.4 or later. Use `OMIDMediaEvents` instead.
 * @see OMIDMediaEvents
 */
- (void)firstQuartile __deprecated_msg("Use -[OMIDMediaEvents firstQuartile]");

/**
 * DEPRECATED. Notifies all video listeners that video playback has reached the midpoint.
 *
 * Warning:
 *  * This class will be fully removed in OM SDK 1.3.4 or later. Use `OMIDMediaEvents` instead.
 * @see OMIDMediaEvents
 */
- (void)midpoint __deprecated_msg("Use -[OMIDMediaEvents midpoint]");

/**
 * DEPRECATED. Notifies all video listeners that video playback has reached the third quartile.
 *
 * Warning:
 *  * This class will be fully removed in OM SDK 1.3.4 or later. Use `OMIDMediaEvents` instead.
 * @see OMIDMediaEvents
 */
- (void)thirdQuartile __deprecated_msg("Use -[OMIDMediaEvents thirdQuartile]");

/**
 * DEPRECATED. Notifies all video listeners that video playback is complete.
 *
 * Warning:
 *  * This class will be fully removed in OM SDK 1.3.4 or later. Use `OMIDMediaEvents` instead.
 * @see OMIDMediaEvents
 */
- (void)complete __deprecated_msg("Use -[OMIDMediaEvents complete]");

/**
 * DEPRECATED. Notifies all video listeners that video playback has paused after a user interaction.
 *
 * Warning:
 *  * This class will be fully removed in OM SDK 1.3.4 or later. Use `OMIDMediaEvents` instead.
 * @see OMIDMediaEvents
 */
- (void)pause __deprecated_msg("Use -[OMIDMediaEvents pause]");

/**
 * DEPRECATED. Notifies all video listeners that video playback has resumed (after being paused)
 * after a user interaction.
 *
 * Warning:
 *  * This class will be fully removed in OM SDK 1.3.4 or later. Use `OMIDMediaEvents` instead.
 * @see OMIDMediaEvents
 */
- (void)resume __deprecated_msg("Use -[OMIDMediaEvents resume]");

/**
 * DEPRECATED. Notifies all video listeners that video playback has stopped as a user skip
 * interaction. Once skipped video it should not be possible for the video to resume playing
 * content.
 *
 * Warning:
 *  * This class will be fully removed in OM SDK 1.3.4 or later. Use `OMIDMediaEvents` instead.
 * @see OMIDMediaEvents
 */
- (void)skipped __deprecated_msg("Use -[OMIDMediaEvents skipped]");

/**
 * DEPRECATED. Notifies all video listeners that video playback has stopped and started buffering.
 *
 * Warning:
 *  * This class will be fully removed in OM SDK 1.3.4 or later. Use `OMIDMediaEvents` instead.
 * @see OMIDMediaEvents
 */
- (void)bufferStart __deprecated_msg("Use -[OMIDMediaEvents bufferStart]");

/**
 * DEPRECATED. Notifies all video listeners that buffering has finished and video playback has
 * resumed.
 *
 * Warning:
 *  * This class will be fully removed in OM SDK 1.3.4 or later. Use `OMIDMediaEvents` instead.
 * @see OMIDMediaEvents
 */
- (void)bufferFinish __deprecated_msg("Use -[OMIDMediaEvents bufferFinish]");

/**
 * DEPRECATED. Notifies all video listeners that the video player volume has changed.
 *
 * @param playerVolume The volume from the native video player with a range between 0 and 1.
 *
 * Warning:
 *  * This class will be fully removed in OM SDK 1.3.4 or later. Use `OMIDMediaEvents` instead.
 * @see OMIDMediaEvents
 */
- (void)volumeChangeTo:(CGFloat)playerVolume
    __deprecated_msg("Use -[OMIDMediaEvents volumeChangeTo:]");

/**
 * DEPRECATED. Notifies all video listeners that video player state has changed. See {@link
 * OMIDPlayerState} for list of supported states.
 *
 * @param playerState The latest video player state.
 *
 * Warning:
 *  * This class will be fully removed in OM SDK 1.3.4 or later. Use `OMIDMediaEvents` instead.
 * @see OMIDMediaEvents
 */
- (void)playerStateChangeTo:(OMIDPlayerState)playerState
    __deprecated_msg("Use -[OMIDMediaEvents playerStateChangeTo:]");

/**
 * DEPRECATED. Notifies all video listeners that the user has performed an ad interaction. See
 * {@link OMIDInteractionType} for list of supported types.
 *
 * @param interactionType The latest user integration.
 *
 * Warning:
 *  * This class will be fully removed in OM SDK 1.3.4 or later. Use `OMIDMediaEvents` instead.
 * @see OMIDMediaEvents
 */
- (void)adUserInteractionWithType:(OMIDInteractionType)interactionType
    NS_SWIFT_NAME(adUserInteraction(withType:))
        __deprecated_msg("Use -[OMIDMediaEvents adUserInteractionWithType:]");

@end
