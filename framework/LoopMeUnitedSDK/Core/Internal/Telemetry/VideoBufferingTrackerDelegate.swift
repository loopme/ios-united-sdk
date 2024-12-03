//
//  VideoBufferingTrackerDelegate.swift
//  LoopMeUnitedSDK
//
//  Created by Lukasz Tomaszewski on 05/11/2024.
//

import Foundation

// Define the delegate protocol
@objc(LoopMeVideoBufferingTrackerDelegate) public protocol VideoBufferingTrackerDelegate {
    func videoBufferingTracker(_ tracker: VideoBufferingTracker, didCaptureEvent event: VideoBufferingEvent)
}
