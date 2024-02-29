//
//  AdTrackingLinks.swift
//  LoopMeServerCommuniator
//
//  Created by Bohdan on 8/13/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

import Foundation

public struct ProgressEvent: Hashable {

    public static func == (lhs: ProgressEvent, rhs: ProgressEvent) -> Bool {
        return lhs.link == rhs.link && lhs.offset == rhs.offset
    }

    public var link: String
    public var offset: TimeInterval
}

/// Stores VAST [ViewableImpression](https://iabtechlab.com/wp-content/uploads/2022/09/VAST_4.3.pdf#page=45&zoom=100,84,330)
///
/// # Example: #
///  ```swift
/// var originalVastViewableImpression = ViewableImpression(
///     viewable: ["https://viewable"],
///     notViewable: ["https://notViewable"],
///     viewUndetermined: ["https://viewUndeterminated"]
/// )
/// var wrappedVastViewableImpression = ViewableImpression(
///     viewable: ["https://viewable"],
///     notViewable: ["https://notViewable"],
///     viewUndetermined: ["https://viewUndeterminated"]
/// )
/// // Concatenates each fields of original and wrapped VAST ViewableImpression
/// originalVastViewableImpression += wrappedVastViewableImpression
/// ```
struct ViewableImpression: Equatable {
    
    static func +=(lhs: inout ViewableImpression, rhs: ViewableImpression) {
        lhs.viewable.formUnion(rhs.viewable)
        lhs.notViewable.formUnion(rhs.notViewable)
        lhs.viewUndetermined.formUnion(rhs.viewUndetermined)
    }
    
    public static func == (lhs: ViewableImpression, rhs: ViewableImpression) -> Bool {
        return
            lhs.viewable == rhs.viewable &&
            lhs.notViewable == rhs.notViewable &&
            lhs.viewUndetermined == rhs.viewUndetermined
    }
    
    public var viewable: Set<String> = []
    public var notViewable: Set<String> = []
    public var viewUndetermined: Set<String> = []
}

/// Stores VAST [Linear Tracking Events](https://iabtechlab.com/wp-content/uploads/2022/09/VAST_4.3.pdf#page=68)
///
/// # Example: #
///  ```swift
/// var originalVastTracking = LinearTracking()
/// var wrappedVastTracking = LinearTracking()
/// // Concatenates each fields of original and wrapped VAST Tracking Events
/// originalVastTracking += wrappedVastTracking
/// ```
struct LinearTracking: Equatable {
    
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
    
    public static func == (lhs: LinearTracking, rhs: LinearTracking) -> Bool {
        return
            lhs.loaded == rhs.loaded &&
            lhs.start == rhs.start &&
            lhs.firstQuartile == rhs.firstQuartile &&
            lhs.midpoint == rhs.midpoint &&
            lhs.thirdQuartile == rhs.thirdQuartile &&
            lhs.complete == rhs.complete &&
            lhs.mute == rhs.mute &&
            lhs.unmute == rhs.unmute &&
            lhs.pause == rhs.pause &&
            lhs.resume == rhs.resume &&
            lhs.fullscreen == rhs.fullscreen &&
            lhs.exitFullscreen == rhs.exitFullscreen &&
            lhs.skip == rhs.skip &&
            lhs.close == rhs.close &&
            lhs.expand == rhs.expand &&
            lhs.collapse == rhs.collapse &&
            lhs.click == rhs.click &&
            lhs.companionClick == rhs.companionClick &&
            lhs.progress == rhs.progress
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

/// Stores all VAST URIs for tracking/redirects
///
/// # Example: #
///  ```swift
/// var originalAdTracking = AdTrackingLinks()
/// var wrappedAdTracking = AdTrackingLinks()
/// // Concatenates each fields of original and wrapped VAST Tracking/Redirect fields
/// originalAdTracking += wrappedAdTracking
/// ```
struct AdTrackingLinks: Equatable {
    
    static func += (lhs: inout AdTrackingLinks, rhs: AdTrackingLinks) {
        lhs.errorTemplates.formUnion(rhs.errorTemplates)
        lhs.verificationNotExecuted.formUnion(rhs.verificationNotExecuted)
        lhs.impression.formUnion(rhs.impression)
        lhs.clickVideo = rhs.clickVideo == "" ? lhs.clickVideo : rhs.clickVideo
        lhs.clickCompanion = rhs.clickCompanion == "" ? lhs.clickCompanion : rhs.clickCompanion
        lhs.creativeViewCompanion.formUnion(rhs.creativeViewCompanion)
        lhs.viewableImpression += rhs.viewableImpression
        lhs.linear += rhs.linear
    }
    
    public static func == (lhs: AdTrackingLinks, rhs: AdTrackingLinks) -> Bool {
        return
            lhs.errorTemplates == rhs.errorTemplates &&
            lhs.verificationNotExecuted == rhs.verificationNotExecuted &&
            lhs.impression == rhs.impression &&
            lhs.clickVideo == rhs.clickVideo &&
            lhs.clickCompanion == rhs.clickCompanion &&
            lhs.creativeViewCompanion == rhs.creativeViewCompanion &&
            lhs.viewableImpression == rhs.viewableImpression &&
            lhs.linear == rhs.linear
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
