//
//  TelemetryError.swift
//  LoopMeUnitedSDK
//
//  Created by Lukasz Tomaszewski on 30/10/2024.
//

import Foundation

enum TelemetryError: Error, CustomStringConvertible, Equatable {
    case missingRequiredAttributes(eventType: TelemetryEventType, missingAttributes: [EventAttribute])
    case typeMismatch(attribute: EventAttribute, expectedType: Any.Type, actualType: Any.Type)
    case invalidEventType(eventType: String)
    
    var description: String {
        switch self {
        case .missingRequiredAttributes(let eventType, let missingAttributes):
            let attributeNames = missingAttributes.map { $0.rawValue }.joined(separator: ", ")
            return "Telemetry Error: Missing required attributes for event type '\(eventType.rawValue)': [\(attributeNames)]"
            
        case .typeMismatch(let attribute, let expectedType, let actualType):
            return "Telemetry Error: Type mismatch for attribute '\(attribute.rawValue)'. Expected \(expectedType), got \(actualType)"
            
        case .invalidEventType(let eventType):
            return "Telemetry Error: Invalid event type '\(eventType)'"
        }
    }
    
    static func == (lhs: TelemetryError, rhs: TelemetryError) -> Bool {
        switch (lhs, rhs) {
        case (.missingRequiredAttributes(let lhsEventType, let lhsMissingAttributes),
              .missingRequiredAttributes(let rhsEventType, let rhsMissingAttributes)):
            return lhsEventType == rhsEventType && lhsMissingAttributes == rhsMissingAttributes
            
        case (.typeMismatch(let lhsAttribute, let lhsExpectedType, let lhsActualType),
              .typeMismatch(let rhsAttribute, let rhsExpectedType, let rhsActualType)):
            return lhsAttribute == rhsAttribute &&
                   lhsExpectedType == rhsExpectedType &&
                   lhsActualType == rhsActualType
            
        case (.invalidEventType(let lhsEventType), .invalidEventType(let rhsEventType)):
            return lhsEventType == rhsEventType
            
        default:
            return false
        }
    }
}
