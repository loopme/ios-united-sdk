//
//  EventAttributeValueTests.swift
//  LoopMeUnitedSDK
//
//  Created by Lukasz Tomaszewski on 30/10/2024.
//

import Foundation
import Testing
@testable import LoopMeUnitedSDK

struct EventAttributeValueTests {
    
    @Test("Test initialization with correct String Type", arguments: [
        EventAttribute.device_os,
        EventAttribute.device_id,
        EventAttribute.device_model,
        EventAttribute.device_os_ver,
        EventAttribute.device_manufacturer,
        EventAttribute.sdk_type,
        EventAttribute.session_id,
        EventAttribute.mediation,
        EventAttribute.msg,
        EventAttribute.sdk_version,
        EventAttribute.mediation_sdk_version,
        EventAttribute.package,
        EventAttribute.type,
        EventAttribute.ifv,
        EventAttribute.impression_id,
        EventAttribute.platform,
        EventAttribute.version,
        EventAttribute.adapter_version,
        EventAttribute.app_key,
        EventAttribute.cid,
        EventAttribute.crid,
        EventAttribute.placement
    ])
    func testInitializationWithCorrectStringType(attribute: EventAttribute) {
        let value = "12345"
        let eventAttributeValue = try? EventAttributeValue(attribute: attribute, value: value)
        #expect(eventAttributeValue != nil)
        #expect(eventAttributeValue?.attribute == attribute)
        #expect((eventAttributeValue?.value as? String) == value)
    }

    @Test("Test initialization with incorrect type for String Attribute")
    func testInitializationWithIncorrectTypeForStringAttribute() throws {
        let attribute = EventAttribute.device_os
        let value = 12345 // Incorrect type (Int instead of String)
        
        #expect(throws: TelemetryError.typeMismatch(attribute: .device_os, expectedType: String.self, actualType: Int.self),
                performing: { try EventAttributeValue(attribute: attribute, value: value) })
    }
    
    @Test("Test initialization with correct Int Type", arguments: [
        EventAttribute.duration,
        EventAttribute.duration_avg
    ])
    func testInitializationWithCorrectIntType(attribute: EventAttribute) {
        let value = 120
        let eventAttributeValue = try? EventAttributeValue(attribute: attribute, value: value)
        #expect(eventAttributeValue != nil)
        #expect(eventAttributeValue?.attribute == attribute)
        #expect((eventAttributeValue?.value as? Int) == value)
    }

    @Test("Test initialization with incorrect type for Int Attribute")
    func testInitializationWithIncorrectTypeForIntAttribute() {
        let attribute = EventAttribute.duration
        let value = "incorrect type" // Incorrect type (String instead of Int)
        
        #expect(throws: TelemetryError.typeMismatch(attribute: .duration, expectedType: Int.self, actualType: String.self),
                performing: { try EventAttributeValue(attribute: attribute, value: value) })
    }

    @Test("Test initialization with correct Date Type")
    func testInitializationWithCorrectDateType() {
        let attribute = EventAttribute.created_at
        let value = Date()
        let eventAttributeValue = try? EventAttributeValue(attribute: attribute, value: value)
        #expect(eventAttributeValue != nil)
        #expect(eventAttributeValue?.attribute == attribute)
        #expect((eventAttributeValue?.value as? Date) == value)
    }
    
    @Test("Test initialization with incorrect type for Date Attribute")
    func testInitializationWithIncorrectTypeForDateAttribute() {
        let attribute = EventAttribute.created_at
        let value = "incorrect type" // Incorrect type (String instead of Date)
        
        #expect(throws: TelemetryError.typeMismatch(attribute: .created_at, expectedType: Date.self, actualType: String.self),
                performing: { try EventAttributeValue(attribute: attribute, value: value) })
    }
}
