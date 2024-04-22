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
    private let videoEvents: OMIDLoopmeAdEvents
    private let mediaEvents: OMIDLoopmeMediaEvents

    @objc public init(session: OMIDLoopmeAdSession) throws {
        self.sentEvents = []
        do {
            self.videoEvents = try OMIDLoopmeAdEvents(adSession: session)
            self.mediaEvents = try OMIDLoopmeMediaEvents(adSession: session)
        } catch {
            throw error
        }
    }
    
    @objc public func loaded(with vastProperties: OMIDLoopmeVASTProperties) {
        if !sentEvents.contains(LoopMeOMIDVideoEvents.adLoaded) {
            sentEvents.insert(LoopMeOMIDVideoEvents.adLoaded)
            do {
                   try videoEvents.loaded(with: vastProperties)
               } catch {
                   // Handle the error here
                   print("Error: Loaded vast properties ")
               }
        }
    }
    
    @objc public func start(withDuration duration: CGFloat, videoPlayerVolume: CGFloat) {
        if !sentEvents.contains(LoopMeOMIDVideoEvents.adStarted) {
            sentEvents.insert(LoopMeOMIDVideoEvents.adStarted)
            mediaEvents.start(withDuration: duration, mediaPlayerVolume: videoPlayerVolume)
        }
    }
    
    @objc public func firstQuartile() {
        if !sentEvents.contains(LoopMeOMIDVideoEvents.adVideoFirstQuartile) {
            sentEvents.insert(LoopMeOMIDVideoEvents.adVideoFirstQuartile)
            mediaEvents.firstQuartile()
        }
    }
    
    @objc public func midpoint() {
        if !sentEvents.contains(LoopMeOMIDVideoEvents.adVideoMidpoint) {
            sentEvents.insert(LoopMeOMIDVideoEvents.adVideoMidpoint)
            mediaEvents.midpoint()
        }
    }
    
    @objc public func thirdQuartile() {
        if !sentEvents.contains(LoopMeOMIDVideoEvents.adVideoThirdQuartile) {
            sentEvents.insert(LoopMeOMIDVideoEvents.adVideoThirdQuartile)
            mediaEvents.thirdQuartile()
        }
    }
    
    @objc public func complete() {
        if !sentEvents.contains(LoopMeOMIDVideoEvents.adComplete) {
            sentEvents.insert(LoopMeOMIDVideoEvents.adComplete)
            mediaEvents.complete()
        }
    }
    
    @objc public func pause() {
        if sentEvents.contains(LoopMeOMIDVideoEvents.adStarted) {
            mediaEvents.pause()
        }
    }
    
    @objc public func resume() {
        mediaEvents.resume()
    }
    
    @objc public func skipped() {
        if !sentEvents.contains(LoopMeOMIDVideoEvents.adSkipped) {
            sentEvents.insert(LoopMeOMIDVideoEvents.adSkipped)
            mediaEvents.skipped()
        }
    }
    
    @objc public func volumeChange(to playerVolume: CGFloat) {
        mediaEvents.volumeChange(to: playerVolume)
    }
    
    @objc public func adUserInteraction(withType interactionType: OMIDInteractionType) {
        mediaEvents.adUserInteraction(withType: interactionType)
    }
}
