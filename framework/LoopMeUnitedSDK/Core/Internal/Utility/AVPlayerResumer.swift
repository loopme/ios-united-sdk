//
//  AVPlayerResumer.swift
//  LoopMeUnitedSDK
//
//  Created by Lukasz Tomaszewski on 08/11/2024.
//

import Foundation
import AVFoundation

@objcMembers
@objc(LoopMeAVPlayerResumer)
public final class AVPlayerResumer: NSObject {
    private weak var player: AVPlayer?
    private weak var playerItem: AVPlayerItem?
    private var playbackStarted: Bool = false

    private var playbackLikelyToKeepUpObserver: NSKeyValueObservation?
    private var playbackBufferFullObserver: NSKeyValueObservation?
    private var videoStartedObserver: NSKeyValueObservation?
    private var currentItemObserver: NSKeyValueObservation?

    // Private debug mode property
    /// Enables or disables debug logging. Default is `false`.
    private var isDebugMode: Bool = true

    // Private identifier for distinguishing instances
    private let identifier: String

    /// Initializes the AVPlayerResumer with an AVPlayer.
    /// - Parameters:
    ///   - player: The AVPlayer instance to monitor.
    ///   - debugMode: Optional parameter to enable debug mode.
    public init(player: AVPlayer) {
        self.player = player
        self.identifier = AVPlayerResumer.generateIdentifier()
        super.init()
        log("Initialized AVPlayerResumer with player: \(player)")
        observeCurrentItem()
        setupObservers(for: player.currentItem)
    }

    deinit {
        log("Deinitializing AVPlayerResumer")
        removeObservers()
        currentItemObserver?.invalidate()
    }

    private func observeCurrentItem() {
        guard let player else {
            log("observeCurrentItem: Player is nil")
            return
        }
        log("Observing 'currentItem' of player")
        currentItemObserver = player.observe(\.currentItem, options: [.new, .initial]) { [weak self] player, _ in
            guard let self = self else { return }
            self.log("'currentItem' did change")
            self.removeObservers()
            self.setupObservers(for: player.currentItem)
        }
    }

    private func setupObservers(for item: AVPlayerItem?) {
        guard let player else {
            log("setupObservers: Player is nil")
            return
        }
        guard let item else {
            log("setupObservers: Item is nil")
            return
        }

        // Check if the item's asset is a remote URL
        if !isRemoteAsset(item.asset) {
            log("Item's asset is local. Shutting down AVPlayerResumer.")
            removeObservers()
            self.playerItem = nil
            return
        }

        self.playerItem = item
        log("Setting up observers for item: \(item)")

        // Observe video started to make sure it should resume in case of buffering
        videoStartedObserver = player.observe(\.rate, changeHandler: { [weak self] player, _ in
            guard let self = self else { return }
            if !player.rate.isNaN && !player.rate.isZero && !self.playbackStarted {
                self.playbackStarted = true
                self.log("Playback started")
            }
        })

        // Observe playbackLikelyToKeepUp
        playbackLikelyToKeepUpObserver = item.observe(\.isPlaybackLikelyToKeepUp, options: [.new]) { [weak self] item, _ in
            guard let self = self else { return }
            self.log("KVO: 'isPlaybackLikelyToKeepUp' changed to \(item.isPlaybackLikelyToKeepUp)")
            if item.isPlaybackLikelyToKeepUp && self.playbackStarted {
                self.log("Resuming playback due to 'isPlaybackLikelyToKeepUp'")
                self.resumePlaybackIfNeeded()
            }
        }

        // Observe playbackBufferFull
        playbackBufferFullObserver = item.observe(\.isPlaybackBufferFull, options: [.new])  { [weak self] item, _ in
            guard let self = self else { return }
            guard let player = self.player else { return }
            self.log("KVO: 'isPlaybackBufferFull' changed to \(item.isPlaybackBufferFull)")
            if item.isPlaybackBufferFull && player.rate.isZero && self.playbackStarted {
                self.log("Resuming playback due to 'isPlaybackBufferFull'")
                self.resumePlaybackIfNeeded()
            }
        }
    }

    private func removeObservers() {
        playbackLikelyToKeepUpObserver?.invalidate()
        playbackLikelyToKeepUpObserver = nil
        playbackBufferFullObserver?.invalidate()
        playbackBufferFullObserver = nil
        videoStartedObserver?.invalidate()
        videoStartedObserver = nil
        log("Removed observers")
    }

    private func resumePlaybackIfNeeded() {
        guard let player else {
            log("resumePlaybackIfNeeded: Player is nil")
            return
        }
        if player.timeControlStatus != .playing {
            player.play()
            log("Resumed playback")
        } else {
            log("Player is already playing")
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
        log("isRemoteAsset: Asset is not AVURLAsset. Assuming not remote")
        return false
    }

    /// Logs messages when debug mode is enabled.
    /// - Parameter message: The message to log.
    private func log(_ message: String) {
        if isDebugMode {
            print("[AVPlayerResumer][\(identifier)] \(message)")
        }
    }

    /// Generates a random 4-letter identifier.
    private static func generateIdentifier() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0..<4).compactMap { _ in letters.randomElement() })
    }
}
