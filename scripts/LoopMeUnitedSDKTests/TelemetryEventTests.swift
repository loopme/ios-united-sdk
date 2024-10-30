//
//  TelemetryEvent.swift
//  LoopMeUnitedSDK
//
//  Created by Lukasz Tomaszewski on 30/10/2024.
//

import Foundation
import Testing
@testable import LoopMeUnitedSDK

struct TelemetryEventTests {
    
    @Test("Test sessionStart event with valid attributes")
    func testSessionStartEventWithValidAttributes() {
        let attributes = [
            try! EventAttributeValue(attribute: .session_id, value: "session123"),
            try! EventAttributeValue(attribute: .created_at, value: Date()),
            try! EventAttributeValue(attribute: .mediation, value: "mediation"),
            try! EventAttributeValue(attribute: .platform, value: "iOS"),
            try! EventAttributeValue(attribute: .version, value: "1.0"),
            try! EventAttributeValue(attribute: .adapter_version, value: "adapter1"),
            try! EventAttributeValue(attribute: .package, value: "com.example.app")
        ]
        
        let event = try? TelemetryEvent(type: .sessionStart, attributes: attributes)
        #expect(event != nil)
        #expect(event?.type == .sessionStart)
        #expect(event?.attributes.count == attributes.count)
    }
    
    @Test("Test sessionEnd event with missing duration attribute")
    func testSessionEndEventWithMissingDurationAttribute() {
        let attributes = [
            try! EventAttributeValue(attribute: .session_id, value: "session123"),
            try! EventAttributeValue(attribute: .created_at, value: Date()),
            try! EventAttributeValue(attribute: .mediation, value: "mediation"),
            try! EventAttributeValue(attribute: .platform, value: "iOS"),
            try! EventAttributeValue(attribute: .version, value: "1.0"),
            try! EventAttributeValue(attribute: .adapter_version, value: "adapter1"),
            try! EventAttributeValue(attribute: .package, value: "com.example.app")
        ]
        
        let expectedError = TelemetryError.missingRequiredAttributes(eventType: .sessionEnd, missingAttributes: [.duration])
        
        #expect(throws: expectedError, performing: {
            try TelemetryEvent(type: .sessionEnd, attributes: attributes)
        })
    }
    
    @Test("Test adBidResponseDuration event with valid attributes")
    func testAdBidResponseDurationEventWithValidAttributes() {
        let attributes = [
            try! EventAttributeValue(attribute: .session_id, value: "session123"),
            try! EventAttributeValue(attribute: .impression_id, value: "impression789"),
            try! EventAttributeValue(attribute: .created_at, value: Date()),
            try! EventAttributeValue(attribute: .mediation, value: "mediation"),
            try! EventAttributeValue(attribute: .platform, value: "iOS"),
            try! EventAttributeValue(attribute: .version, value: "1.0"),
            try! EventAttributeValue(attribute: .adapter_version, value: "adapter1"),
            try! EventAttributeValue(attribute: .package, value: "com.example.app"),
            try! EventAttributeValue(attribute: .duration, value: 150)
        ]
        
        let event = try? TelemetryEvent(type: .adBidResponseDuration, attributes: attributes)
        #expect(event != nil)
        #expect(event?.type == .adBidResponseDuration)
        #expect(event?.attributes.count == attributes.count)
    }
    
    @Test("Test adDisplayDuration event with missing impression_id")
    func testAdDisplayDurationEventWithMissingImpressionId() {
        let attributes = [
            try! EventAttributeValue(attribute: .session_id, value: "session123"),
            try! EventAttributeValue(attribute: .created_at, value: Date()),
            try! EventAttributeValue(attribute: .mediation, value: "mediation"),
            try! EventAttributeValue(attribute: .platform, value: "iOS"),
            try! EventAttributeValue(attribute: .version, value: "1.0"),
            try! EventAttributeValue(attribute: .adapter_version, value: "adapter1"),
            try! EventAttributeValue(attribute: .package, value: "com.example.app"),
            try! EventAttributeValue(attribute: .duration, value: 300)
        ]
        
        let expectedError = TelemetryError.missingRequiredAttributes(eventType: .adDisplayDuration, missingAttributes: [.impression_id])
        
        #expect(throws: expectedError, performing: {
            try TelemetryEvent(type: .adDisplayDuration, attributes: attributes)
        })
    }
}
