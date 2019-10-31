//
//  VastProperties.swift
//  LoopMeServerCommuniator
//
//  Created by Bohdan on 8/13/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

import UIKit

public class VastProperties: NSObject {
    public var adId: String?
    public var duration: TimeInterval = 0
    public var skipOffset: VastSkipOffset = .empty
    public var adTagURI: String?
    var trackingLinks = AdTrackingLinks()
    var assetLinks = AssetLinks()
    var adVerifications: [AdVerification] = []
    
    public var isWrapper: Bool = false
    
    var lastParent: Node?
    var currentXmlNode: Node?
    var tempMediaFiles: [Node] = []
}

extension VastProperties: XMLParserDelegate {
    
    convenience init(xmlString: String) throws {
        guard let data = xmlString.data(using: .utf8) else {
            throw XMLError.notvalid
        }
        
        self.init(data: data)
    }
    
    convenience init(data: Data) {
        self.init()
        
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
    }
    
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        currentXmlNode = XMLNode(name: elementName, props: attributeDict, parent: lastParent, content: nil)
        lastParent = currentXmlNode
        
        switch elementName {
        case "Wrapper":
            self.isWrapper = true
        case "InLine":
            self.isWrapper = false
        case "Creative":
            if self.adId == nil || self.adId!.isEmpty {
                self.adId = attributeDict["id"]
            }
        case "Linear":
            guard let skipOffsetString = attributeDict["skipoffset"] else { return }
            
            if skipOffsetString.contains("%") {
                skipOffset.type = .percent
                if let value = Double(skipOffsetString.filter("01234567890.".contains)) {
                    skipOffset.value = value
                }
            } else {
                skipOffset.type = .seconds
                let value =  Converter.timeInterval(from: skipOffsetString)
                skipOffset.value = value
            }
        case "Verification":
            if currentXmlNode?.parent?.name == "AdVerifications" {
                var verification = AdVerification.empty
                if let vendor = attributeDict["vendor"] {
                    verification.vendor = vendor
                }
                adVerifications.append(verification)
             }
        default:
            break
        }
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        lastParent = lastParent?.parent
        
        switch elementName {
        case "MediaFile":
            guard let node = currentXmlNode else { return }
            tempMediaFiles.append(node)
        case "MediaFiles":
            do {
                try parseMediaFiles()
            } catch {
                print("parseMediaFiles error")
            }
        default:
            break
        }
    }
    
    public func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        guard let value = String(data: CDATABlock, encoding: .utf8) else { return }
        self.parser(parser, foundCharacters: value)
    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard let currentName = currentXmlNode?.name else { return }
        
        let parent = currentXmlNode?.parent ?? XMLNode(name: "", props: [:], parent: nil, content: nil)
        
        let string = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if string.isEmpty {
            return
        }
        
        switch currentName {
        case "Impression":
            if parent.name == "InLine" || parent.name == "Wrapper" {
                trackingLinks.impression.insert(string)
            }
        case "Error":
            if parent.name == "InLine" || parent.name == "Wrapper" {
                trackingLinks.errorTemplates.insert(string)
            }
        case "Viewable":
            if parent.name == "ViewableImpression" {
                trackingLinks.viewableImpression.viewable.insert(string)
            }
        case "NotViewable":
            if parent.name == "ViewableImpression" {
                trackingLinks.viewableImpression.notViewable.insert(string)
            }
        case "ViewUndetermined":
            if parent.name == "ViewableImpression"{
                trackingLinks.viewableImpression.viewUndetermined.insert(string)
            }
        case "Duration":
            self.duration = Converter.timeInterval(from: string)
        case "Tracking":
            if parent.name == "TrackingEvents", let event = currentXmlNode?.props["event"] {
                if event == "progress" {
                    parseTracking(event: event, value: string, offset: currentXmlNode?.props["offset"])
                } else {
                    parseTracking(event: event, value: string, offset: nil)
                }
            }
        case "ClickThrough":
            if parent.name == "VideoClicks" {
                trackingLinks.clickVideo = string
            }
        case "ClickTracking":
            trackingLinks.linear.click.insert(string)
        case "CompanionClickTracking":
            trackingLinks.linear.companionClick.insert(string)
        case "CompanionClickThrough":
            if parent.name == "Companion" {
                trackingLinks.clickCompanion = string
            }
        case "MediaFile":
            currentXmlNode?.content = string
        case "StaticResource":
            if let creativeType = currentXmlNode?.props["creativeType"], creativeType == "image/jpeg" {
                assetLinks.endCard.insert(string)
            }
        case "JavaScriptResource":
            var verification = adVerifications.removeLast()
            verification.jsResource = string
            adVerifications.append(verification)
        case "VerificationParameters":
            var verification = adVerifications.removeLast()
            verification.verificationParameters = string
            adVerifications.append(verification)
        case "VASTAdTagURI":
            self.adTagURI = string
        case "AdParameters":
            self.assetLinks.adParameters = string
        default:
            break
        }
    }
    
    private func parseTracking(event: String, value: String, offset: String? = "") {
        switch event {
        case "start":
            trackingLinks.linear.start.insert(value)
        case "firstQuartile":
            trackingLinks.linear.firstQuartile.insert(value)
        case "midpoint":
            trackingLinks.linear.midpoint.insert(value)
        case "thirdQuartile":
            trackingLinks.linear.thirdQuartile.insert(value)
        case "complete":
            trackingLinks.linear.complete.insert(value)
        case "mute":
            trackingLinks.linear.mute.insert(value)
        case "unmute":
            trackingLinks.linear.unmute.insert(value)
        case "pause":
            trackingLinks.linear.pause.insert(value)
        case "resume":
            trackingLinks.linear.resume.insert(value)
        case "fullscreen":
            trackingLinks.linear.fullscreen.insert(value)
        case "exitFullscreen":
            trackingLinks.linear.exitFullscreen.insert(value)
        case "skip":
            trackingLinks.linear.skip.insert(value)
        case "close":
            trackingLinks.linear.close.insert(value)
        case "playerExpand":
            trackingLinks.linear.expand.insert(value)
        case "playerCollapse":
            trackingLinks.linear.collapse.insert(value)
        case "creativeView":
            trackingLinks.creativeViewCompanion.insert(value)
        case "verificationNotExecuted":
            trackingLinks.verificationNotExecuted.insert(value)
        case "loaded":
            trackingLinks.linear.loaded.insert(value)
        case "progress":
            let seconds: TimeInterval
            if let offset = offset {
                seconds = Converter.timeInterval(from: offset)
            } else {
                seconds = 0
            }
            let progress = ProgressEvent(link: value, offset: seconds)
            trackingLinks.linear.progress.insert(progress)
        default:
            break
        }
    }
    
    func parseMediaFiles() throws {
        try tempMediaFiles.sort(by: sortMediaFilesBlock)
        var videoURLs: [String] = []
        for mediaFileNode in tempMediaFiles {
            let delivery = mediaFileNode.props["delivery"]
            let framework = mediaFileNode.props["apiFramework"]
            let type = mediaFileNode.props["type"]
            if let content = mediaFileNode.content {
                if delivery == "progressive" && type == "video/mp4" {
                    videoURLs.append(content.trimmingCharacters(in: .whitespacesAndNewlines))
                } else if framework == "VPAID" && type == "application/javascript" {
                    assetLinks.vpaidURL = content.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }
        assetLinks.videoURL = videoURLs
    }
    
    func sortMediaFilesBlock(node1: Node, node2: Node) throws -> Bool {
        var screenSize = UIScreen.main.bounds.size
        if screenSize.height > screenSize.width {
            screenSize = CGSize(width: screenSize.height, height: screenSize.width)
        }
        
        guard let widthString1 = node1.props["width"],
                let width1 = Double(widthString1),
                let widthString2 = node2.props["width"],
                let width2 = Double(widthString2),
                let heightString1 = node1.props["height"],
                let height1 = Double(heightString1),
                let heightString2 = node2.props["height"],
                let height2 = Double(heightString2) else {
                throw XMLError.mediaFilesProperties
        }
        
        let delta1 = fabs(Double(screenSize.width) - width1) + fabs(Double(screenSize.height) - height1);
        let delta2 = fabs(Double(screenSize.width) - width2) + fabs(Double(screenSize.height) - height2);
        
        return delta1 > delta2
    }
}
