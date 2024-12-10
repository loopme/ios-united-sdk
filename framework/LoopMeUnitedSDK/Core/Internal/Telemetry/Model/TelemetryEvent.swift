//
//  TelemetryEvent.swift
//  LoopMeUnitedSDK
//
//  Created by Lukasz Tomaszewski on 29/10/2024.
//

import Foundation

@objc(TelemetryEvent)
class TelemetryEvent: NSObject {
    @objc let id: String
    @objc let type: String
    @objc let attributes: NSDictionary
    
    @objc init(id: String = UUID().uuidString, type: String, attributes: NSDictionary) {
        self.id = id
        self.type = type
        self.attributes = attributes
    }
    
    func toDictionary() -> [String: Any] {
        return ["id": id, "type": type, "attributes": attributes]
    }
    
    func toNSDictionary() -> NSDictionary {
        return toDictionary() as NSDictionary
    }
    
    @objc static func from(dictionary: NSDictionary) -> TelemetryEvent? {
        guard let type = dictionary["type"] as? String,
              let attributes = dictionary["attributes"] as? NSDictionary else {
            return nil
        }
        return TelemetryEvent(type: type, attributes: attributes)
    }
}
