//
//  EventAttribute+Type.swift
//  LoopMeUnitedSDK
//
//  Created by Lukasz Tomaszewski on 29/10/2024.
//

import Foundation

extension EventAttribute {
    var expectedType: Any.Type {
        switch self {
        case .created_at: Date.self
        case .device_os, .device_id, .device_model, .device_os_ver, .device_manufacturer, .sdk_type, .session_id, .mediation, .msg, .sdk_version, .mediation_sdk_version, .package, .type, .ifv, .impression_id, .platform, .version, .adapter_version, .app_key, .cid, .crid, .placement, .media_url:
            String.self
        case .duration, .duration_avg:
            Int.self
        }
    }
}
