//
//  VideoBufferingEvent.swift
//  LoopMeUnitedSDK
//
//  Created by Lukasz Tomaszewski on 05/11/2024.
//

import Foundation

// Define the class for the buffering event
@objcMembers
@objc(LoopMeVideoBufferingEvent)
public class VideoBufferingEvent: NSObject {
    let duration: NSNumber        // Total buffering time in seconds
    let durationAvg: NSNumber     // Average buffering time per buffering event in seconds
    let bufferCount: NSNumber     // Total number of buffering events
    let mediaURL: URL             // URL of the media being played

    @objc public init(duration: NSNumber, durationAvg: NSNumber, bufferCount: NSNumber, mediaURL: URL) {
        self.duration = duration
        self.durationAvg = durationAvg
        self.bufferCount = bufferCount
        self.mediaURL = mediaURL
    }
}
