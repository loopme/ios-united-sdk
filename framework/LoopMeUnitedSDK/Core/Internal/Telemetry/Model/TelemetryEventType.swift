//
//  TelemetryEventType.swift
//  LoopMeUnitedSDK
//
//  Created by Lukasz Tomaszewski on 30/10/2024.
//

import Foundation

@objc(TelemetryEventType)
public class TelemetryEventType: NSObject {
    @objc public static let sessionStart = "session_start"
    @objc public static let sessionEnd = "session_end"
    @objc public static let initializationDuration = "initialization_duration"
    @objc public static let adBidResponseDuration = "ad_bid_response_duration"
    @objc public static let adLoadDuration = "ad_load_duration"
    @objc public static let videoBufferingAverage = "video_buffering_average"
    @objc public static let adDisplayDuration = "ad_display_duration"

    @objc public static func requiredAttributes(for eventType: String) -> NSMutableDictionary {
        let attributes: [String]
        switch eventType {
            case sessionStart:
                attributes = [
                    EventAttribute.session_id,
                    EventAttribute.created_at,
                    EventAttribute.mediation,
                    EventAttribute.platform,
                    EventAttribute.sdk_version,
                    EventAttribute.mediation_sdk_version,
                    EventAttribute.adapter_version,
                    EventAttribute.package
                ]
            case sessionEnd:
                attributes = [
                    EventAttribute.session_id,
                    EventAttribute.created_at,
                    EventAttribute.mediation,
                    EventAttribute.platform,
                    EventAttribute.versionNumber,
                    EventAttribute.adapter_version,
                    EventAttribute.package,
                    EventAttribute.duration
                ]
            case initializationDuration:
                attributes = [
                    EventAttribute.session_id,
                    EventAttribute.created_at,
                    EventAttribute.mediation,
                    EventAttribute.platform,
                    EventAttribute.versionNumber,
                    EventAttribute.adapter_version,
                    EventAttribute.package,
                    EventAttribute.duration
                ]
            case adBidResponseDuration:
                attributes = [
                    EventAttribute.session_id,
                    EventAttribute.impression_id,
                    EventAttribute.created_at,
                    EventAttribute.mediation,
                    EventAttribute.platform,
                    EventAttribute.versionNumber,
                    EventAttribute.adapter_version,
                    EventAttribute.package,
                    EventAttribute.duration
                ]
            case adLoadDuration:
                attributes = [
                    EventAttribute.session_id,
                    EventAttribute.impression_id,
                    EventAttribute.created_at,
                    EventAttribute.mediation,
                    EventAttribute.platform,
                    EventAttribute.versionNumber,
                    EventAttribute.adapter_version,
                    EventAttribute.package,
                    EventAttribute.duration
                ]
            case videoBufferingAverage:
                attributes = [
                    EventAttribute.session_id,
                    EventAttribute.impression_id,
                    EventAttribute.created_at,
                    EventAttribute.mediation,
                    EventAttribute.platform,
                    EventAttribute.versionNumber,
                    EventAttribute.adapter_version,
                    EventAttribute.package,
                    EventAttribute.duration_avg,
                    EventAttribute.media_url
                ]
            case adDisplayDuration:
                attributes = [
                    EventAttribute.session_id,
                    EventAttribute.impression_id,
                    EventAttribute.created_at,
                    EventAttribute.mediation,
                    EventAttribute.platform,
                    EventAttribute.versionNumber,
                    EventAttribute.adapter_version,
                    EventAttribute.package,
                    EventAttribute.duration
                ]
            default:
                attributes = []
            }

        let dictionary = NSMutableDictionary()
        for key in attributes {
            dictionary[key] = NSNull()
        }
        return dictionary
    }
}
