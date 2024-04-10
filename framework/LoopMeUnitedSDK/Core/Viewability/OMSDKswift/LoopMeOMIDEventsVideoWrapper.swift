//
//  LoopMeOMIDEventsVideoWrapper.swift
//  LoopMeUnitedSDK
//
//  Created by Valerii Roman on 09/04/2024.
//  Copyright © 2024 LoopMe. All rights reserved.
//

import Foundation
import OMSDK_Loopme

struct LoopMeOMIDVideoEvents {
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

class LoopMeOMIDVideoEventsWrapper {
    private var sentEvents = Set<String>()
    private let videoEvents: OMIDLoopmeMediaEvents

    init(session: OMIDLoopmeAdSession) throws {
        self.sentEvents = []
        do {
            self.videoEvents = try OMIDLoopmeMediaEvents(adSession: session)
        } catch {
            throw error
        }
    }
    
    func loaded(with vastProperties: OMIDLoopmeVASTProperties) {
        if !sentEvents.contains(LoopMeOMIDVideoEvents.adLoaded) {
            sentEvents.insert(LoopMeOMIDVideoEvents.adLoaded)
            videoEvents.loaded(with: vastProperties)
        }
    }
    
    func start(withDuration duration: CGFloat, videoPlayerVolume: CGFloat) {
        if !sentEvents.contains(LoopMeOMIDVideoEvents.adStarted) {
            sentEvents.insert(LoopMeOMIDVideoEvents.adStarted)
            videoEvents.start(withDuration: duration, mediaPlayerVolume: videoPlayerVolume)
        }
    }
    
    func firstQuartile() {
        if !sentEvents.contains(LoopMeOMIDVideoEvents.adVideoFirstQuartile) {
            sentEvents.insert(LoopMeOMIDVideoEvents.adVideoFirstQuartile)
            videoEvents.firstQuartile()
        }
    }
    
    func midpoint() {
        if !sentEvents.contains(LoopMeOMIDVideoEvents.adVideoMidpoint) {
            sentEvents.insert(LoopMeOMIDVideoEvents.adVideoMidpoint)
            videoEvents.midpoint()
        }
    }
    
    func thirdQuartile() {
        if !sentEvents.contains(LoopMeOMIDVideoEvents.adVideoThirdQuartile) {
            sentEvents.insert(LoopMeOMIDVideoEvents.adVideoThirdQuartile)
            videoEvents.thirdQuartile()
        }
    }
    
    func complete() {
        if !sentEvents.contains(LoopMeOMIDVideoEvents.adComplete) {
            sentEvents.insert(LoopMeOMIDVideoEvents.adComplete)
            videoEvents.complete()
        }
    }
    
    func pause() {
        if sentEvents.contains(LoopMeOMIDVideoEvents.adStarted) {
            videoEvents.pause()
        }
    }
    
    func resume() {
        videoEvents.resume()
    }
    
    func skipped() {
        if !sentEvents.contains(LoopMeOMIDVideoEvents.adSkipped) {
            sentEvents.insert(LoopMeOMIDVideoEvents.adSkipped)
            videoEvents.skipped()
        }
    }
    
    func volumeChange(to playerVolume: CGFloat) {
        videoEvents.volumeChange(to: playerVolume)
    }
    
    func adUserInteraction(withType interactionType: OMIDInteractionType) {
        videoEvents.adUserInteraction(withType: interactionType)
    }
}
