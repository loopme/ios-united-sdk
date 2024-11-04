//
//  TelemetryEvent.swift
//  LoopMeUnitedSDK
//
//  Created by Lukasz Tomaszewski on 29/10/2024.
//

import Foundation

struct TelemetryEvent {
    let id: String = UUID().uuidString
    let type: TelemetryEventType
    let attributes: [EventAttributeValue]
    
    init(type: TelemetryEventType, attributes: [EventAttributeValue]) throws {
        self.type = type
        self.attributes = attributes
        try validateAttributes()
    }
    
    func toDictionary() -> [String: Any] {
        var dictionary: [String: Any] = ["msg": type.rawValue]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        attributes.forEach { attributeValue in
            let key = attributeValue.attribute.rawValue
            let value = attributeValue.value
            
            if let dateValue = value as? Date {
                dictionary[key] = dateFormatter.string(from: dateValue)
            } else {
                dictionary[key] = value
            }
        }
        return dictionary
    }

    
    private func validateAttributes() throws {
        let attributeKeys = Set(attributes.map { $0.attribute })
        let requiredKeys = Set(type.requiredAttributes)
        
        if !requiredKeys.isSubset(of: attributeKeys) {
            let missingAttributes = Array(requiredKeys.subtracting(attributeKeys))
            throw TelemetryError.missingRequiredAttributes(eventType: type, missingAttributes: missingAttributes)
        }
        
        for attribute in attributes {
            let expectedType = attribute.attribute.expectedType
            if Swift.type(of: attribute.value) != expectedType {
                throw TelemetryError.typeMismatch(attribute: attribute.attribute,
                                                  expectedType: expectedType,
                                                  actualType: Swift.type(of: attribute.value))
            }
        }
    }
}
