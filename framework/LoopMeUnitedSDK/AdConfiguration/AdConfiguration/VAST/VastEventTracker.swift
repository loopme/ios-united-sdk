//
//  VastEventTracker.swift
//  LoopMeServerCommuniator
//
//  Created by Bohdan on 8/27/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

import Foundation

@objc (LoopMeVASTEventType)
public enum VASTEventType: Int {
    case impression
    case linearStart
    case linearFirstQuartile
    case linearMidpoint
    case linearThirdQuartile
    case linearComplete
    case linearClose
    case linearPause
    case linearResume
    case linearExpand
    case linearCollapse
    case linearSkip
    case linearMute
    case linearUnmute
    case linearProgress
    case linearClickTracking
    case companionCreativeView
    case companionClickTracking

    case viewable
    case notViewable
    case viewUndetermined
}

struct VastEventTracker {
    
    private var links: AdTrackingLinks
    private var sentEvents: Set<VASTEventType> = []
    private var sentProgress: Set<Double> = []
    private var currentTime: TimeInterval = 0

    init(trackingLinks: AdTrackingLinks) {
        self.links = trackingLinks
    }
    
    mutating func track(event: VASTEventType) {
        if self.sentEvents.contains(event) {
            return
        }
        
        let eventURLs: Set<String>
        
        switch event {
        case .impression:
            eventURLs = self.links.impression
        case .linearStart:
            eventURLs = self.links.linear.start
        case .linearFirstQuartile:
            eventURLs = self.links.linear.firstQuartile
        case .linearMidpoint:
            eventURLs = self.links.linear.midpoint
        case .linearThirdQuartile:
            eventURLs = self.links.linear.thirdQuartile
        case .linearComplete:
            eventURLs = self.links.linear.complete
        case .linearClose:
//            [self trackEvent: LoopMeVASTEventTypeViewable];
            eventURLs = self.links.linear.close
        case .linearPause:
            eventURLs = self.links.linear.pause
        case .linearResume:
            eventURLs = self.links.linear.resume
        case .linearExpand:
            eventURLs = self.links.linear.expand
        case .linearCollapse:
            eventURLs = self.links.linear.collapse
        case .linearSkip:
            eventURLs = self.links.linear.skip
        case .linearMute:
            eventURLs = self.links.linear.mute
        case .linearUnmute:
            eventURLs = self.links.linear.unmute
        case .linearClickTracking:
            eventURLs = self.links.linear.click
        case .companionCreativeView:
            eventURLs = self.links.creativeViewCompanion
        case .companionClickTracking:
            eventURLs = self.links.linear.companionClick
        case .viewable:
            eventURLs = self.links.viewableImpression.viewable
        case .notViewable:
            eventURLs = self.links.viewableImpression.notViewable
        case .viewUndetermined:
            eventURLs = self.links.viewableImpression.viewUndetermined
        default:
            eventURLs = []
        }
        
        track(urls: Array(eventURLs))
        sentEvents.insert(event)
    
        if event == .viewable {
            sentEvents.insert(.notViewable)
        }
        
        if event == .notViewable {
            sentEvents.insert(.viewable)
        }
        
    }
    
    private mutating func track(url: String) {
        if let url = URL(string: url), let urlMacro = VASTMacroProcessor.macroExpandedURL(for: url, errorCode: 0, videoTimeOffset: self.currentTime, videoAssetURL: nil) {
            
            URLSession.shared.dataTask(with: urlMacro).resume()
        }
    }
    
    mutating func track(urls: Array<String>) {
        for urlStr in urls {
            track(url: urlStr)
        }
    }
    
    func track(error code: Int) {
        let errorTemplates = self.links.errorTemplates
        for template in errorTemplates {
            if let url = URL(string: template), let processedUrl = VASTMacroProcessor.macroExpandedURL(for: url, errorCode: code) {
                URLSession.shared.dataTask(with: processedUrl).resume()
            }
        }
    }
    
    func trackAdVerificationNonExecuted() {
        let adVerificationErrorTemplates = self.links.verificationNotExecuted;
        let reason = 2
        for template in adVerificationErrorTemplates {
            if let url = URL(string: template), let processedUrl = VASTMacroProcessor.macroExpandedURL(for: url, errorCode: reason) {
                URLSession.shared.dataTask(with: processedUrl).resume()
            }
        }
    }
    
    mutating func setCurrentTime(currentTime: TimeInterval) {
        self.currentTime = currentTime;
        let progressLinks = self.links.linear.progress
        
        for event in progressLinks {
            if !self.sentProgress.contains(event.offset + 60) {
                if currentTime > event.offset {
                    if let url = URL(string: event.link) {
                        URLSession.shared.dataTask(with: url).resume()
                        self.sentProgress.insert(event.offset + 60)
                    }
                }
            }
        }
    }
}
