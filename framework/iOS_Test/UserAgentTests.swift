//
//  UserAgentTests.swift
//  iOS_Test
//
//  Created by Valerii Roman on 24/05/2024.
//  Copyright © 2024 LoopMe. All rights reserved.
//

import XCTest

@testable import LoopMeUnitedSDK

class UserAgentTests: XCTestCase {

    func testDefaultUserAgent() {
        // Arrange
        let expectedUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 13_0_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0 Mobile/15E148 Safari/604.1"
        
        // Act
        let userAgent = UserAgent.defaultUserAgent
        
        // Assert
        XCTAssertEqual(userAgent, expectedUserAgent)
    }
    
    func testOSVersionUnderlined() {
         // Arrange
         let expectedOSVersion = "13_0_1"
         
         // Act
         let osVersion = UserAgent.OSVersionUnderlined
         
         // Assert
         XCTAssertEqual(osVersion, expectedOSVersion)
     }
     
     func testSafariVersion() {
         // Arrange
         let expectedSafariVersion = "13.0.1"
         
         // Act
         let safariVersion = UserAgent.safariVersion
         
         // Assert
         XCTAssertEqual(safariVersion, expectedSafariVersion)
     }
     
     func testDevice() {
         // Arrange
         let expectedDevice = "iPhone"
         
         // Act
         let device = UserAgent.device
         
         // Assert
         XCTAssertEqual(device, expectedDevice)
     }
     
     func testOS() {
         // Arrange
         let expectedOS = "CPU iPhone OS"
         
         // Act
         let os = UserAgent.OS
         
         // Assert
         XCTAssertEqual(os, expectedOS)
     }
}
