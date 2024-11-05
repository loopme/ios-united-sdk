//
//  VideoBufferingTracker.swift
//  LoopMeUnitedSDK
//
//  Created by Lukasz Tomaszewski on 05/11/2024.
//

import Foundation
import AVFoundation
import UIKit

@objcMembers
@objc(LoopMeVideoBufferingTracker)
public class VideoBufferingTracker: NSObject {
    private weak var player: AVPlayer?
    private var playerItemContext = 0
    private var isObserving = false
    private var bufferingStartTime: Date?
    private var totalBufferingDuration: TimeInterval = 0
    private var bufferCount: Int = 0
    private var isBuffering = false
    private var currentPlayerItem: AVPlayerItem?
    private var mediaURL: URL?

    // Delegate property
    @objc private weak var delegate: VideoBufferingTrackerDelegate?

    // Debug mode property
    /// Enables or disables debug logging. Default is `false`.
    @objc public var isDebugMode: Bool = false

    /// Initializes the VideoBufferingTracker with an AVPlayer and a delegate.
    /// - Parameters:
    ///   - player: The AVPlayer instance to monitor.
    ///   - delegate: The delegate to receive buffering events.
    public init(player: AVPlayer, delegate: VideoBufferingTrackerDelegate?) {
        super.init()
        self.player = player
        self.delegate = delegate
        log("Initialized VideoBufferingTracker with player: \(player)")
        addObservers()
    }

    /// Adds necessary observers to the AVPlayer and its current item.
    private func addObservers() {
        guard let player = player else {
            log("addObservers: Player is nil")
            return
        }

        // Observe the currentItem property of the player
        player.addObserver(self, forKeyPath: "currentItem", options: [.old, .new], context: &playerItemContext)
        log("Added observer for 'currentItem'")

        // Observe when player item ends
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(_:)), name: .AVPlayerItemDidPlayToEndTime, object: player)
        log("Added observer for AVPlayerItemDidPlayToEndTime")

        // Observe app entering background
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: player)
        log("Added observer for UIApplication.didEnterBackgroundNotification")

        isObserving = true
        observePlayerItem(player.currentItem)
    }

    /// Removes all observers from the AVPlayer and its current item.
    private func removeObservers() {
        guard isObserving, let player = player else {
            log("removeObservers: No observers to remove")
            return
        }

        player.removeObserver(self, forKeyPath: "currentItem", context: &playerItemContext)
        log("Removed observer for 'currentItem'")

        NotificationCenter.default.removeObserver(self)
        log("Removed all NotificationCenter observers")

        unobservePlayerItem(currentPlayerItem)

        isObserving = false
    }

    /// Observes specific properties of the given AVPlayerItem.
    /// - Parameter item: The AVPlayerItem to observe.
    private func observePlayerItem(_ item: AVPlayerItem?) {
        guard let item = item else {
            log("observePlayerItem: Item is nil")
            return
        }

        // Check if the item's asset is a remote URL
        if !isRemoteAsset(item.asset) {
            log("observePlayerItem: Asset is not remote. Canceling tracking.")
            cancelTracking()
            return
        }

        item.addObserver(self, forKeyPath: "playbackBufferEmpty", options: [.old, .new], context: &playerItemContext)
        log("Added observer for 'playbackBufferEmpty'")

        item.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: [.old, .new], context: &playerItemContext)
        log("Added observer for 'playbackLikelyToKeepUp'")

        currentPlayerItem = item
        mediaURL = (item.asset as? AVURLAsset)?.url
        log("Observing new player item with URL: \(mediaURL?.absoluteString ?? "nil")")

        // Observe when the item finishes playing
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(_:)), name: .AVPlayerItemDidPlayToEndTime, object: item)
        log("Added observer for AVPlayerItemDidPlayToEndTime on new item")
    }

    /// Stops observing specific properties of the given AVPlayerItem.
    /// - Parameter item: The AVPlayerItem to stop observing.
    private func unobservePlayerItem(_ item: AVPlayerItem?) {
        guard let item = item else {
            log("unobservePlayerItem: Item is nil")
            return
        }

        item.removeObserver(self, forKeyPath: "playbackBufferEmpty", context: &playerItemContext)
        log("Removed observer for 'playbackBufferEmpty'")

        item.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp", context: &playerItemContext)
        log("Removed observer for 'playbackLikelyToKeepUp'")

        // Remove the notification observer for this item
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: item)
        log("Removed observer for AVPlayerItemDidPlayToEndTime on item")

        currentPlayerItem = nil
    }

    /// Cancels all tracking and resets internal state.
    @objc public func cancelTracking() {
        log("Cancelling tracking and resetting state")
        removeObservers()
        totalBufferingDuration = 0
        bufferingStartTime = nil
        bufferCount = 0
        isBuffering = false
        mediaURL = nil
    }

    /// Handles the event when the player finishes playing an item.
    /// - Parameter notification: The notification object.
    @objc private func playerDidFinishPlaying(_ notification: Notification) {
        log("Player did finish playing")
        // Send the buffering event data
        sendBufferingEvent()
    }

    /// Handles the event when the application enters the background.
    /// - Parameter notification: The notification object.
    @objc private func applicationDidEnterBackground(_ notification: Notification) {
        log("Application did enter background")
        // Send the buffering event data
        sendBufferingEvent()
    }

    /// Called when the user skips the ad.
    @objc public func userDidSkipAd() {
        log("User did skip ad")
        sendBufferingEvent()
    }

    /// Sends the collected buffering event data to the delegate.
    private func sendBufferingEvent() {
        log("Sending buffering event")

        // Ensure buffering has ended
        if isBuffering {
            bufferingEnded()
        }

        // Calculate duration in seconds
        let duration = totalBufferingDuration
        // Calculate average duration per buffering event
        let durationAvg = bufferCount > 0 ? Double(duration) / Double(bufferCount) : 0.0

        // Only send event if total buffering duration is greater than 0
        guard duration > 0, let mediaURL = mediaURL else {
            log("sendBufferingEvent: No buffering duration or mediaURL available. Event not sent.")
            return
        }

        let event = VideoBufferingEvent(
            duration: NSNumber(value: duration),
            durationAvg: NSNumber(value: durationAvg),
            bufferCount: NSNumber(value: bufferCount),
            mediaURL: mediaURL
        )

        log("Buffering Event - Duration: \(duration), Avg: \(durationAvg), Count: \(bufferCount), URL: \(mediaURL)")

        delegate?.videoBufferingTracker(self, didCaptureEvent: event)

        // Reset tracking data
        totalBufferingDuration = 0
        bufferingStartTime = nil
        bufferCount = 0
    }

    /// Observes changes to the player's properties using KVO.
    public override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }

        if keyPath == "currentItem" {
            log("KVO: 'currentItem' changed")
            // Handle player item change
            if let oldItem = change?[.oldKey] as? AVPlayerItem {
                log("KVO: Unobserving old item")
                unobservePlayerItem(oldItem)
            }
            if let newItem = change?[.newKey] as? AVPlayerItem {
                log("KVO: Observing new item")
                observePlayerItem(newItem)
            }
        } else if keyPath == "playbackBufferEmpty" {
            if let isBufferEmpty = (change?[.newKey] as AnyObject).boolValue, isBufferEmpty {
                log("KVO: 'playbackBufferEmpty' detected - Buffering started")
                // Buffering started
                bufferingStarted()
            }
        } else if keyPath == "playbackLikelyToKeepUp" {
            if let isLikelyToKeepUp = (change?[.newKey] as AnyObject).boolValue, isLikelyToKeepUp {
                log("KVO: 'playbackLikelyToKeepUp' detected - Buffering ended")
                // Buffering ended
                bufferingEnded()
            }
        }
    }

    /// Marks the start of a buffering event.
    private func bufferingStarted() {
        if !isBuffering {
            isBuffering = true
            bufferingStartTime = Date()
            bufferCount += 1
            log("Buffering started at \(bufferingStartTime!)")
        }
    }

    /// Marks the end of a buffering event and updates the total duration.
    private func bufferingEnded() {
        if isBuffering {
            isBuffering = false
            if let startTime = bufferingStartTime {
                let bufferingDuration = Date().timeIntervalSince(startTime)
                totalBufferingDuration += bufferingDuration
                log("Buffering ended. Duration: \(bufferingDuration) seconds")
                bufferingStartTime = nil
            }
        }
    }

    /// Determines if the given AVAsset is a remote asset.
    /// - Parameter asset: The AVAsset to check.
    /// - Returns: `true` if the asset is remote; otherwise, `false`.
    private func isRemoteAsset(_ asset: AVAsset) -> Bool {
        if let urlAsset = asset as? AVURLAsset {
            let isRemote = !urlAsset.url.isFileURL
            log("isRemoteAsset: URL is remote? \(isRemote)")
            return isRemote
        }
        log("isRemoteAsset: Asset is not AVURLAsset. Returning false")
        return false
    }

    /// Logs messages when debug mode is enabled.
    /// - Parameter message: The message to log.
    private func log(_ message: String) {
        if isDebugMode {
            print("[VideoBufferingTracker] \(message)")
        }
    }

    /// Cleans up observers when the instance is deallocated.
    deinit {
        log("Deinitializing VideoBufferingTracker")
        removeObservers()
    }
}
