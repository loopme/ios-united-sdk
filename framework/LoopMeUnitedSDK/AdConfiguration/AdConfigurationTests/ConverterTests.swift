//
//  ConverterTests.swift
//  LoopMeUnitedSDKTests
//
//  Created by Evgen Epanchin on 26.02.2024.
//  Copyright © 2024 LoopMe. All rights reserved.
//

import XCTest
@testable import LoopMeUnitedSDK

final class ConverterTests: XCTestCase {
    func testCorrectFormat() throws {
        XCTAssertEqual(Converter.timeInterval(from: "00:01:59"), 59);
        XCTAssertEqual(Converter.timeInterval(from: "00:00:59"), 59);
        XCTAssertEqual(Converter.timeInterval(from: "00:00:00"), 00);
        XCTAssertEqual(Converter.timeInterval(from: "00:00:30"), 30);
    }
    
    func testInCorrectFormat() throws {
        XCTAssertEqual(Converter.timeInterval(from: ""), 0);
        XCTAssertEqual(Converter.timeInterval(from: "00:00:65"), 0);
        XCTAssertEqual(Converter.timeInterval(from: "15"), 0);
        XCTAssertEqual(Converter.timeInterval(from: "abc"), 0);
        XCTAssertEqual(Converter.timeInterval(from: "30%"), 0);
    }
}
