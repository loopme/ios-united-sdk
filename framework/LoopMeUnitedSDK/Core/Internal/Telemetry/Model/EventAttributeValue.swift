//
//  EventAttributeValue.swift
//  LoopMeUnitedSDK
//
//  Created by Lukasz Tomaszewski on 29/10/2024.
//

import Foundation

struct EventAttributeValue {
    let attribute: EventAttribute
    let value: Any
    
    init<T>(attribute: EventAttribute, value: T) throws {
        guard attribute.expectedType == T.self else {
            throw TelemetryError.typeMismatch(attribute: attribute, expectedType: attribute.expectedType, actualType: T.self)
        }
        self.attribute = attribute
        self.value = value
    }
}
