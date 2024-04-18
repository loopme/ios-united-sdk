//
//  LoopMeOMIDEventsVideoWrapper.swift
//  LoopMeUnitedSDK
//
//  Created by Valerii Roman on 09/04/2024.
//  Copyright © 2024 LoopMe. All rights reserved.
//

import Foundation
import OMSDK_Loopme

public struct LoopMeOMIDVideoEvents {
    static let adStarted = "recordAdStartedEvent"
    static let adLoaded = "recordAdLoadedEvent"
    static let adComplete = "recordAdCompleteEvent"
    static let adVideoFirstQuartile = "recordAdVideoFirstQuartileEvent"
    static let adVideoMidpoint = "recordAdVideoMidpointEvent"
    static let adVideoThirdQuartile = "recordAdVideoThirdQuartileEvent"
    static let adPaused = "recordAdPausedEvent"
    static let adExpandedChange = "recordAdExpandedChangeEvent"
    static let adResume = "recordAdResume"
    static let adSkipped = "recordAdSkippedEvent"
    static let adVolumeChangeEvent = "recordAdVolumeChangeEvent:"
}

@objc (LoopMeOMIDVideoEventsWrapper)
public class OMIDVideoEventsWrapper: NSObject {
    private var sentEvents = Set<String>()
    private let videoEvents: OMIDLoopmeMediaEvents
    
    @objc public init(session: OMIDLoopmeAdSession) throws {
        self.sentEvents = []
        do {
            self.videoEvents = try OMIDLoopmeMediaEvents(adSession: session)
        } catch {
            throw error
        }
    }
    
    @objc public func loaded(with vastProperties: OMIDLoopmeVASTProperties) {
        if !sentEvents.contains(LoopMeOMIDVideoEvents.adLoaded) {
            sentEvents.insert(LoopMeOMIDVideoEvents.adLoaded)
            videoEvents.loaded(with: vastProperties)
        }
    }
    
    @objc public func start(withDuration duration: CGFloat, videoPlayerVolume: CGFloat) {
        if !sentEvents.contains(LoopMeOMIDVideoEvents.adStarted) {
            sentEvents.insert(LoopMeOMIDVideoEvents.adStarted)
            videoEvents.start(withDuration: duration, mediaPlayerVolume: videoPlayerVolume)
        }
    }
    
    @objc public func firstQuartile() {
        if !sentEvents.contains(LoopMeOMIDVideoEvents.adVideoFirstQuartile) {
            sentEvents.insert(LoopMeOMIDVideoEvents.adVideoFirstQuartile)
            videoEvents.firstQuartile()
        }
    }
    
    @objc public func midpoint() {
        if !sentEvents.contains(LoopMeOMIDVideoEvents.adVideoMidpoint) {
            sentEvents.insert(LoopMeOMIDVideoEvents.adVideoMidpoint)
            videoEvents.midpoint()
        }
    }
    
    @objc public func thirdQuartile() {
        if !sentEvents.contains(LoopMeOMIDVideoEvents.adVideoThirdQuartile) {
            sentEvents.insert(LoopMeOMIDVideoEvents.adVideoThirdQuartile)
            videoEvents.thirdQuartile()
        }
    }
    
    @objc public func complete() {
        if !sentEvents.contains(LoopMeOMIDVideoEvents.adComplete) {
            sentEvents.insert(LoopMeOMIDVideoEvents.adComplete)
            videoEvents.complete()
        }
    }
    
    @objc public func pause() {
        if sentEvents.contains(LoopMeOMIDVideoEvents.adStarted) {
            videoEvents.pause()
        }
    }
    
    @objc public func resume() {
        videoEvents.resume()
    }
    
    @objc public func skipped() {
        if !sentEvents.contains(LoopMeOMIDVideoEvents.adSkipped) {
            sentEvents.insert(LoopMeOMIDVideoEvents.adSkipped)
            videoEvents.skipped()
        }
    }
    
    @objc public func volumeChange(to playerVolume: CGFloat) {
        videoEvents.volumeChange(to: playerVolume)
    }
    
    @objc public func adUserInteraction(withType interactionType: OMIDInteractionType) {
        videoEvents.adUserInteraction(withType: interactionType)
    }
}
