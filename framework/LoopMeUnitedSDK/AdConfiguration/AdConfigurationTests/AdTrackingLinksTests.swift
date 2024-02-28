//
//  AdTrackingLinksTests.swift
//  LoopMeUnitedSDKTests
//
//  Created by Evgen Epanchin on 27.02.2024.
//  Copyright © 2024 LoopMe. All rights reserved.
//

import XCTest

@testable import LoopMeUnitedSDK

// ViewableImpression mocks
var emptyViewableImpression = ViewableImpression()
var leftViewableImpression = ViewableImpression(
    viewable: ["https://viewableLeft"],
    notViewable: ["https://notViewableLeft"],
    viewUndetermined: ["https://viewUndeterminatedLeft"]
)
var rightViewableImpression = ViewableImpression(
    viewable: ["https://viewableRight"],
    notViewable: ["https://notViewableRight"],
    viewUndetermined: ["https://viewUndeterminatedRight"]
)
var concatenatedViewableImpression = ViewableImpression(
    viewable: ["https://viewableLeft", "https://viewableRight"],
    notViewable: ["https://notViewableLeft", "https://notViewableRight"],
    viewUndetermined: ["https://viewUndeterminatedLeft", "https://viewUndeterminatedRight"]
)

// LinearTracking mocks
var emptyLinearTracking = LinearTracking()
var leftLinearTracking = LinearTracking(
    loaded: ["loadedLeft"],
    start: ["startLeft"],
    firstQuartile: ["firstQuartileLeft"],
    midpoint: ["midpointLeft"],
    thirdQuartile: ["thirdQuartileLeft"],
    complete: ["completeLeft"],
    mute: ["muteLeft"],
    unmute: ["unmuteLeft"],
    pause: ["pauseLeft"],
    resume: ["resumeLeft"],
    fullscreen: ["fullscreenLeft"],
    exitFullscreen: ["exitFullscreenLeft"],
    skip: ["skipLeft"],
    close: ["closeLeft"],
    expand: ["expandLeft"],
    collapse: ["collapseLeft"],
    click: ["clickLeft"],
    companionClick: ["companionClickLeft"],
    progress: [ProgressEvent(link: "progressLinkLeft", offset: 0)]
)
var rightLinearTracking = LinearTracking(
    loaded: ["loadedRight"],
    start: ["startRight"],
    firstQuartile: ["firstQuartileRight"],
    midpoint: ["midpointRight"],
    thirdQuartile: ["thirdQuartileRight"],
    complete: ["completeRight"],
    mute: ["muteRight"],
    unmute: ["unmuteRight"],
    pause: ["pauseRight"],
    resume: ["resumeRight"],
    fullscreen: ["fullscreenRight"],
    exitFullscreen: ["exitFullscreenRight"],
    skip: ["skipRight"],
    close: ["closeRight"],
    expand: ["expandRight"],
    collapse: ["collapseRight"],
    click: ["clickRight"],
    companionClick: ["companionClickRight"],
    progress: [ProgressEvent(link: "progressLinkRight", offset: 100)]
)
var concatenatedLinearTracking = LinearTracking(
    loaded: ["loadedLeft", "loadedRight"],
    start: ["startLeft", "startRight"],
    firstQuartile: ["firstQuartileLeft", "firstQuartileRight"],
    midpoint: ["midpointLeft", "midpointRight"],
    thirdQuartile: ["thirdQuartileLeft", "thirdQuartileRight"],
    complete: ["completeLeft", "completeRight"],
    mute: ["muteLeft", "muteRight"],
    unmute: ["unmuteLeft", "unmuteRight"],
    pause: ["pauseLeft", "pauseRight"],
    resume: ["resumeLeft", "resumeRight"],
    fullscreen: ["fullscreenLeft", "fullscreenRight"],
    exitFullscreen: ["exitFullscreenLeft", "exitFullscreenRight"],
    skip: ["skipLeft", "skipRight"],
    close: ["closeLeft", "closeRight"],
    expand: ["expandLeft", "expandRight"],
    collapse: ["collapseLeft", "collapseRight"],
    click: ["clickLeft", "clickRight"],
    companionClick: ["companionClickLeft", "companionClickRight"],
    progress: [
        ProgressEvent(link: "progressLinkLeft", offset: 0),
        ProgressEvent(link: "progressLinkRight", offset: 100)
    ]
)

// AdTrackingLinks mocks
var emptyAdTrackingLinks = AdTrackingLinks()
var leftAdTrackingLinks = AdTrackingLinks(
    errorTemplates: ["https://errorTemplatesLeft"],
    verificationNotExecuted: ["https://verificationNotExecutedLeft"],
    impression: ["https://impressionLeft"],
    clickVideo: "clickVideoLeft",
    clickCompanion: "clickCompanionLeft",
    creativeViewCompanion: ["https://creativeViewCompanionLeft"],
    
    viewableImpression: leftViewableImpression,
    linear: leftLinearTracking
)
var rightAdTrackingLinks = AdTrackingLinks(
    errorTemplates: ["https://errorTemplatesRight"],
    verificationNotExecuted: ["https://verificationNotExecutedRight"],
    impression: ["https://impressionRight"],
    clickVideo: "clickVideoRight",
    clickCompanion: "clickCompanionRight",
    creativeViewCompanion: ["https://creativeViewCompanionRight"],
    
    viewableImpression: rightViewableImpression,
    linear: rightLinearTracking
)
var concatenatedAdTrackingLinks = AdTrackingLinks(
    errorTemplates: ["https://errorTemplatesLeft", "https://errorTemplatesRight"],
    verificationNotExecuted: ["https://verificationNotExecutedLeft", "https://verificationNotExecutedRight"],
    impression: ["https://impressionLeft", "https://impressionRight"],
    clickVideo: "clickVideoRight",
    clickCompanion: "clickCompanionRight",
    creativeViewCompanion: ["https://creativeViewCompanionLeft", "https://creativeViewCompanionRight"],
    
    viewableImpression: concatenatedViewableImpression,
    linear: concatenatedLinearTracking
)

private typealias TestCase<T: Equatable> = (lhs: T, rhs: T, expected: T)

private func testCombination<T>(_ cases: [TestCase<T>], using combine: (inout T, T) -> Void) {
    cases.enumerated().forEach { index, item in
        let lhs = item.0
        let rhs = item.1
        let expected = item.2
        var left = lhs
        combine(&left, rhs)
        XCTAssertEqual(left, expected, "\nCheck \(index) case")
    }
}

final class AdTrackingLinksTests: XCTestCase {

    func testAdTrackingLinks() throws {
        testCombination([
            (emptyViewableImpression, emptyViewableImpression, emptyViewableImpression),
            (emptyViewableImpression, rightViewableImpression, rightViewableImpression),
            (leftViewableImpression, emptyViewableImpression, leftViewableImpression),
            (leftViewableImpression, rightViewableImpression, concatenatedViewableImpression),
        ]) { (left, right) in left += right }

        testCombination([
            (emptyLinearTracking, emptyLinearTracking, emptyLinearTracking),
            (emptyLinearTracking, rightLinearTracking, rightLinearTracking),
            (leftLinearTracking, emptyLinearTracking, leftLinearTracking),
            (leftLinearTracking, rightLinearTracking, concatenatedLinearTracking)
        ]) { (left, right) in left += right }
        
        testCombination([
            (emptyAdTrackingLinks, emptyAdTrackingLinks, emptyAdTrackingLinks),
            (emptyAdTrackingLinks, rightAdTrackingLinks, rightAdTrackingLinks),
            (leftAdTrackingLinks, emptyAdTrackingLinks, leftAdTrackingLinks),
            (leftAdTrackingLinks, rightAdTrackingLinks, concatenatedAdTrackingLinks)
        ]) { (left, right) in left += right }
    }
}
