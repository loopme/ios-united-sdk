//
//  EventAttributeValue.swift
//  LoopMeUnitedSDK
//
//  Created by Lukasz Tomaszewski on 29/10/2024.
//

import Foundation

struct EventAttributeValue {
    let attribute: String
    let value: Any

    init<T>(attribute: String, value: T) throws {
        let expectedType = EventAttribute.expectedType(for: attribute)

        let actualType: String
        if value is Int {
            actualType = "Int"
        } else if value is String {
            actualType = "String"
        } else if value is Date {
            actualType = "Date"
        } else {
            actualType = "Unknown"
        }

        guard expectedType == actualType else {
            throw TelemetryError.typeMismatch(
                attribute: attribute,
                expectedType: expectedType,
                actualType: actualType
            )
        }

        self.attribute = attribute
        self.value = value
    }
}
