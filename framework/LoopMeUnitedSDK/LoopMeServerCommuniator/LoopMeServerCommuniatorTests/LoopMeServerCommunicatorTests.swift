//
//  LoopMeServerCommunicatorTests.swift
//  LoopMeServerCommunicatorTests
//
//  Created by Bohdan on 9/26/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

import XCTest

@testable import LoopMeUnitedSDK

extension LoopMeServerCommunicatorTests: LoopMeServerCommunicatorDelegate {
    func serverCommunicatorDidReceiveAd(_ communicator: ServerCommunicator) {
        
    }
    
    func serverCommunicator(_ communicator: ServerCommunicator, didReceive adConfiguration: AdConfigurationWrapper) {
        
        if communicator == self.communicatorSuccess {
            // Make sure we downloaded some data.
            XCTAssertNotNil(adConfiguration, "No configuration was downloaded.")
        }
        
        // Fulfill the expectation to indicate that the background task has finished successfully.
        expectationSuccess.fulfill()
    }
    
    func serverCommunicator(_ communicator: ServerCommunicator, didFailWith error: Error?) {
        // Make sure we downloaded some data.
        
        if communicator == self.communicatorSuccess {
            XCTAssertThrowsError(error)
        } else if communicator == self.communicatorNoAds {
            if let error = error as? ServerError {
                XCTAssert(error.errorDescription == ServerError.noAds.errorDescription)
            } else {
                XCTAssert(false)
            }
        }
            // Fulfill the expectation to indicate that the background task has finished successfully.
        expectationNoAds.fulfill()
    }
}

class LoopMeServerCommunicatorTests: XCTestCase {

   var adResponse: String?
   // Create an expectation for a background download task.
   let expectationSuccess = XCTestExpectation(description: "Ad serving request")
   let expectationNoAds = XCTestExpectation(description: "No ads request")
   var communicatorSuccess: ServerCommunicator!
   var communicatorNoAds: ServerCommunicator!
   
   override func setUp() {
       // Put setup code here. This method is called before the invocation of each test method in the class.
       if let path = Bundle(for: type(of: self)).path(forResource: "ad", ofType: "json", inDirectory: nil) {
           adResponse = try? String(contentsOfFile: path)
       }
       
       communicatorSuccess = ServerCommunicator(delegate: self)
       communicatorNoAds = ServerCommunicator(delegate: self)
   }
   
   func testParse() {
       if let data = adResponse?.data(using: .utf8) {
           let configuration = try? JSONDecoder().decode(AdConfiguration.self, from: data)
           XCTAssertNotNil(configuration)
       } else {
           XCTAssertTrue(false)
       }
   }

   func testAdResponseSuccess() {
       let requestBody: Dictionary<String, Any> = [
         "device" : [
           "devicetype" : 4,
           "w" : 375,
           "h" : 667,
           "js" : 1,
           "ifa" : "48D83A1B-FA07-402A-AE4B-E07AEACF194F",
           "osv" : "13.0",
           "connectiontype" : 2,
           "os" : "iOS",
           "geo" : [
             "lat" : "48.4637",
             "lon" : "35.0391",
             "type" : 1
           ],
           "language" : "ru-UA",
           "make" : "Apple",
           "hwv" : "iPhone9,3",
           "ua" : "Mozilla/5.0 (iPhone; CPU iPhone OS 13_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148",
           "dnt" : "0",
           "model" : "phone",
           "ext" : [
             "phonename" : "gOFEAk01ChgPZWm3GMqKbw==",
             "chargelevel" : "0.580000",
             "timezone" : "+0300",
             "wifiname" : "unknown",
             "plugin" : 1,
             "orientation" : "p"
           ]
         ],
         "tmax" : 250,
         "app" : [
           "id" : "test_interstitial_l",
           "bundle" : "com.loopme.loopmeX",
           "name" : "Tester",
           "version" : "3.5.0"
         ],
         "id" : "41346636-14F4-45F0-94CE-4286BB41E1A6",
         "imp" : [
           [
             "secure" : 1,
             "displaymanagerver" : "7.1.2",
             "banner" : [
               "api" : [
                 2,
                 5
               ],
               "w" : 667,
               "id" : 1,
               "battr" : [
                 3,
                 8
               ],
               "expdir" : [
                 5
               ],
               "h" : 375
             ],
             "id" : 1,
             "metric" : [
               [
                 "type" : "viewability",
                 "vendor" : "moat"
               ],
               [
                 "type" : "viewability",
                 "vendor" : "ias"
               ]
             ],
             "ext" : [
               "supported_techs" : [
                 "VIDEO - for usual MP4 video",
                 "VAST2",
                 "VAST3",
                 "VAST4",
                 "VPAID1",
                 "VPAID2",
                 "MRAID2",
                 "V360"
               ],
               "it" : "normal"
             ],
             "bidfloor" : 0,
             "video" : [
               "maxduration" : 30,
               "protocols" : [
                 2,
                 3,
                 7,
                 8
               ],
               "battr" : [
                 3,
                 8
               ],
               "w" : 667,
               "linearity" : 1,
               "boxingallowed" : 1,
               "h" : 375,
               "skip" : 1,
               "mimes" : [
                 "video/mp4"
               ],
               "startdelay" : 0,
               "delivery" : [
                 2
               ],
               "api" : [
                 2,
                 5
               ],
               "sequence" : 1,
               "minduration" : 5,
               "maxbitrate" : 1024
             ],
             "displaymanager" : "LOOPME_SDK",
             "instl" : 1
           ]
         ],
         "regs" : [
           "coppa" : 0
         ],
         "bcat" : [
           "IAB25-3",
           "IAB25",
           "IAB26"
         ],
         "user" : [
           "ext" : [
             "consent" : 0,
             "consent_type" : -1
           ]
         ]
       ]
       
       // Create a URL for a web page to be downloaded.
       let url = URL(string: "https://loopme.me/api/ortb/ads")!
       
       let requestBodyData = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
       
       communicatorSuccess.load(url: url, requestBody: requestBodyData, method: "POST")
       
       // TODO: Fix broken test
       // Wait until the expectation is fulfilled, with a timeout of 5 seconds.
       // wait(for: [expectationSuccess], timeout: 5.0)
   }
   
   func testAdResponseNoAds() {
       let requestBody: Dictionary<String, Any> = [
         "device" : [
           "devicetype" : 4,
           "w" : 375,
           "h" : 667,
           "js" : 1,
           "ifa" : "48D83A1B-FA07-402A-AE4B-E07AEACF194F",
           "osv" : "13.0",
           "connectiontype" : 2,
           "os" : "iOS",
           "geo" : [
             "lat" : "48.4637",
             "lon" : "35.0391",
             "type" : 1
           ],
           "language" : "ru-UA",
           "make" : "Apple",
           "hwv" : "iPhone9,3",
           "ua" : "Mozilla/5.0 (iPhone; CPU iPhone OS 13_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148",
           "dnt" : "0",
           "model" : "phone",
           "ext" : [
             "phonename" : "gOFEAk01ChgPZWm3GMqKbw==",
             "chargelevel" : "0.580000",
             "timezone" : "+0300",
             "wifiname" : "unknown",
             "plugin" : 1,
             "orientation" : "p"
           ]
         ],
         "tmax" : 250,
         "app" : [
           "id" : "blablabla",
           "bundle" : "com.loopme.loopmeX",
           "name" : "Tester",
           "version" : "3.5.0"
         ],
         "id" : "41346636-14F4-45F0-94CE-4286BB41E1A6",
         "imp" : [
           [
             "secure" : 1,
             "displaymanagerver" : "7.1.2",
             "banner" : [
               "api" : [
                 2,
                 5
               ],
               "w" : 667,
               "id" : 1,
               "battr" : [
                 3,
                 8
               ],
               "expdir" : [
                 5
               ],
               "h" : 375
             ],
             "id" : 1,
             "metric" : [
               [
                 "type" : "viewability",
                 "vendor" : "moat"
               ],
               [
                 "type" : "viewability",
                 "vendor" : "ias"
               ]
             ],
             "ext" : [
               "supported_techs" : [
                 "VIDEO - for usual MP4 video",
                 "VAST2",
                 "VAST3",
                 "VAST4",
                 "VPAID1",
                 "VPAID2",
                 "MRAID2",
                 "V360"
               ],
               "it" : "normal"
             ],
             "bidfloor" : 0,
             "video" : [
               "maxduration" : 30,
               "protocols" : [
                 2,
                 3,
                 7,
                 8
               ],
               "battr" : [
                 3,
                 8
               ],
               "w" : 667,
               "linearity" : 1,
               "boxingallowed" : 1,
               "h" : 375,
               "skip" : 1,
               "mimes" : [
                 "video/mp4"
               ],
               "startdelay" : 0,
               "delivery" : [
                 2
               ],
               "api" : [
                 2,
                 5
               ],
               "sequence" : 1,
               "minduration" : 5,
               "maxbitrate" : 1024
             ],
             "displaymanager" : "LOOPME_SDK",
             "instl" : 1
           ]
         ],
         "regs" : [
           "coppa" : 0
         ],
         "bcat" : [
           "IAB25-3",
           "IAB25",
           "IAB26"
         ],
         "user" : [
           "ext" : [
             "consent" : 0,
             "consent_type" : -1
           ]
         ]
       ]
       
       // Create a URL for a web page to be downloaded.
       let url = URL(string: "https://loopme.me/api/ortb/ads")!
       
       let requestBodyData = try? JSONSerialization.data(withJSONObject: requestBody, options: [])
       
       communicatorNoAds.load(url: url, requestBody: requestBodyData, method: "POST")
       
       // Wait until the expectation is fulfilled, with a timeout of 5 seconds.
       wait(for: [expectationNoAds], timeout: 5.0)
   }

}
