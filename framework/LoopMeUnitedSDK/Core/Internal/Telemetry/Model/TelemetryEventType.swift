//
//  TelemetryEventType.swift
//  LoopMeUnitedSDK
//
//  Created by Lukasz Tomaszewski on 30/10/2024.
//

import Foundation

enum TelemetryEventType: String {
    case sessionStart = "session_start"
    case sessionEnd = "session_end"
    case initializationDuration = "initialization_duration"
    case adBidResponseDuration = "ad_bid_response_duration"
    case adLoadDuration = "ad_load_duration"
    case videoBufferingAverage = "video_buffering_average"
    case adDisplayDuration = "ad_display_duration"
    
    var requiredAttributes: [EventAttribute] {
        switch self {
        case .sessionStart:
            return [.session_id, .created_at, .mediation, .platform, .version, .adapter_version, .package]
        case .sessionEnd:
            return [.session_id, .created_at, .mediation, .platform, .version, .adapter_version, .package, .duration]
        case .initializationDuration:
            return [.session_id, .created_at, .mediation, .platform, .version, .adapter_version, .package, .duration]
        case .adBidResponseDuration:
            return [.session_id, .impression_id, .created_at, .mediation, .platform, .version, .adapter_version, .package, .duration]
        case .adLoadDuration:
            return [.session_id, .impression_id, .created_at, .mediation, .platform, .version, .adapter_version, .package, .duration]
        case .videoBufferingAverage:
            return [.session_id, .impression_id, .created_at, .mediation, .platform, .version, .adapter_version, .package, .duration_avg, .media_url]
        case .adDisplayDuration:
            return [.session_id, .impression_id, .created_at, .mediation, .platform, .version, .adapter_version, .package, .duration]
        }
    }
}
