//
//  AdTrackingLinks.swift
//  LoopMeServerCommuniator
//
//  Created by Bohdan on 8/13/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

import Foundation

struct AdTrackingLinks {
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
    public var viewable: Set<String> = []
    public var notViewable: Set<String> = []
    public var viewUndetermined: Set<String> = []
}

struct LinearTracking {
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
