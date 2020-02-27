//
//  AdTrackingLinks.swift
//  LoopMeServerCommuniator
//
//  Created by Bohdan on 8/13/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

import Foundation

struct AdTrackingLinks {
    
    static func +=(lhs: inout AdTrackingLinks, rhs: AdTrackingLinks) {
        lhs.errorTemplates.formUnion(rhs.errorTemplates)
        lhs.verificationNotExecuted.formUnion(rhs.verificationNotExecuted)
        lhs.impression.formUnion(rhs.impression)
        lhs.creativeViewCompanion.formUnion(rhs.creativeViewCompanion)
        lhs.clickVideo = rhs.clickVideo
        lhs.clickCompanion = rhs.clickCompanion
    }
    
    public var errorTemplates: Set<String> = []
    public var verificationNotExecuted: Set<String> = []
    public var impression: Set<String> = []
    public var clickVideo: String = ""
    public var clickCompanion: String = ""
    public var creativeViewCompanion: Set<String> = []
    
    public var viewableImpression = ViewableImpression()
    public var linear = LinearTracking()
}

struct ViewableImpression {
    
    static func +=(lhs: inout ViewableImpression, rhs: ViewableImpression) {
        lhs.viewable.formUnion(rhs.viewable)
        lhs.notViewable.formUnion(rhs.notViewable)
        lhs.viewUndetermined.formUnion(rhs.viewUndetermined)
    }
    
    public var viewable: Set<String> = []
    public var notViewable: Set<String> = []
    public var viewUndetermined: Set<String> = []
}

struct LinearTracking {
    
    static func +=(lhs: inout LinearTracking, rhs: LinearTracking) {
        lhs.loaded.formUnion(rhs.loaded)
        lhs.start.formUnion(rhs.start)
        lhs.firstQuartile.formUnion(rhs.firstQuartile)
        lhs.midpoint.formUnion(rhs.midpoint)
        lhs.thirdQuartile.formUnion(rhs.thirdQuartile)
        lhs.complete.formUnion(rhs.complete)
        lhs.mute.formUnion(rhs.mute)
        lhs.unmute.formUnion(rhs.unmute)
        lhs.pause.formUnion(rhs.pause)
        lhs.resume.formUnion(rhs.resume)
        lhs.fullscreen.formUnion(rhs.fullscreen)
        lhs.exitFullscreen.formUnion(rhs.exitFullscreen)
        lhs.skip.formUnion(rhs.skip)
        lhs.close.formUnion(rhs.close)
        lhs.expand.formUnion(rhs.expand)
        lhs.collapse.formUnion(rhs.collapse)
        lhs.click.formUnion(rhs.click)
        lhs.companionClick.formUnion(rhs.companionClick)
        lhs.progress.formUnion(rhs.progress)
    }
    
    public var loaded: Set<String> = []
    public var start: Set<String> = []
    public var firstQuartile: Set<String> = []
    public var midpoint: Set<String> = []
    public var thirdQuartile: Set<String> = []
    public var complete: Set<String> = []
    public var mute: Set<String> = []
    public var unmute: Set<String> = []
    public var pause: Set<String> = []
    public var resume: Set<String> = []
    public var fullscreen: Set<String> = []
    public var exitFullscreen: Set<String> = []
    public var skip: Set<String> = []
    public var close: Set<String> = []
    public var expand: Set<String> = []
    public var collapse: Set<String> = []
    public var click: Set<String> = []
    public var companionClick: Set<String> = []
    public var progress: Set<ProgressEvent> = []
}

public struct ProgressEvent: Hashable {
    public var link: String
    public var offset: TimeInterval
}
