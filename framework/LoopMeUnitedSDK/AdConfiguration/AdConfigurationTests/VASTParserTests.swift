//
//  VASTParser.swift
//  LoopMeServerCommuniatorTests
//
//  Created by Bohdan on 8/15/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

import XCTest
@testable import LoopMeUnitedSDK

class VASTParserTests: XCTestCase {
    let expectedAdTracking = AdTrackingLinks(
        errorTemplates: ["https://tk0x1.com/sj/tr?et=ERROR&id=5d51644893aaead75ab169df&meta=MjA0NzgyOTo3Mjg2OjQ4RDgzQTFCLUZBMDctNDAyQS1BRTRCLUUwN0FFQUNGMTk0Rg&ctx=CiQ0OEQ4M0ExQi1GQTA3LTQwMkEtQUU0Qi1FMDdBRUFDRjE5NEYSAlVBGPY4INX-fCoMCAMQwIQ9GAMgwM8kONX-fEABOQ&vastcode=[ERRORCODE]"],
        verificationNotExecuted: ["https://tk0x1.com/verificationNotExecuted?reason=[REASON]"],
        impression: ["https://tk0x1.com/sj/tr?et=INBOX_OPEN&id=5d51644893aaead75ab169df&meta=MjA0NzgyOTo3Mjg2OjQ4RDgzQTFCLUZBMDctNDAyQS1BRTRCLUUwN0FFQUNGMTk0Rg&ctx=CiQ0OEQ4M0ExQi1GQTA3LTQwMkEtQUU0Qi1FMDdBRUFDRjE5NEYSAlVBGPY4INX-fCoMCAMQwIQ9GAMgwM8kONX-fEABOQ",
            "https://track.loopme.me/sj/vt?vt=48D83A1B-FA07-402A-AE4B-E07AEACF194F",
            "https://tk0x1.com/sj/vt?vt=48D83A1B-FA07-402A-AE4B-E07AEACF194F",
            "https://fqtag.com/pixel.cgi?org=TrUza3udrufracrayupr&rt=displayImg&rd=URL&fmt=video&sl=1&a=b56429ba71&cmp=2000154&app=13372281407&gid=48D83A1B-FA07-402A-AE4B-E07AEACF194F&aid=48D83A1B-FA07-402A-AE4B-E07AEACF194F&lat=48.4637&long=35.039&p=2159"
        ],
        clickVideo: "https://tk0x1.com/sj/go/5d51644893aaead75ab169df?meta=MjA0NzgyOTo3Mjg2OjQ4RDgzQTFCLUZBMDctNDAyQS1BRTRCLUUwN0FFQUNGMTk0Rg&ctx=CiQ0OEQ4M0ExQi1GQTA3LTQwMkEtQUU0Qi1FMDdBRUFDRjE5NEYSAlVBGPY4INX-fCoMCAMQwIQ9GAMgwM8kONX-fEABOQ&lmhref=https%3A%2F%2Floopme.com&lmhref=https%3A%2F%2Floopme.com",
        clickCompanion: "https://tk0x1.com/sj/go/5d51644893aaead75ab169df?meta=MjA0NzgyOTo3Mjg2OjQ4RDgzQTFCLUZBMDctNDAyQS1BRTRCLUUwN0FFQUNGMTk0Rg&ctx=CiQ0OEQ4M0ExQi1GQTA3LTQwMkEtQUU0Qi1FMDdBRUFDRjE5NEYSAlVBGPY4INX-fCoMCAMQwIQ9GAMgwM8kONX-fEABOQ&lmhref=https%3A%2F%2Floopme.com&lmhref=https%3A%2F%2Floopme.com",
        creativeViewCompanion: ["https://tk0x1.com/sj/tr?et=COMPANION_SHOW&id=5d51644893aaead75ab169df&meta=MjA0NzgyOTo3Mjg2OjQ4RDgzQTFCLUZBMDctNDAyQS1BRTRCLUUwN0FFQUNGMTk0Rg&ctx=CiQ0OEQ4M0ExQi1GQTA3LTQwMkEtQUU0Qi1FMDdBRUFDRjE5NEYSAlVBGPY4INX-fCoMCAMQwIQ9GAMgwM8kONX-fEABOQ"],
        viewableImpression: ViewableImpression(
            viewable: ["https://tk0x1.com/sj/tr?et=VAST_VIEWABLE&id=5d51644893aaead75ab169df&meta=MjA0NzgyOTo3Mjg2OjQ4RDgzQTFCLUZBMDctNDAyQS1BRTRCLUUwN0FFQUNGMTk0Rg&ctx=CiQ0OEQ4M0ExQi1GQTA3LTQwMkEtQUU0Qi1FMDdBRUFDRjE5NEYSAlVBGPY4INX-fCoMCAMQwIQ9GAMgwM8kONX-fEABOQ"],
            notViewable: ["https://tk0x1.com/sj/tr?et=VAST_NOT_VIEWABLE&id=5d51644893aaead75ab169df&meta=MjA0NzgyOTo3Mjg2OjQ4RDgzQTFCLUZBMDctNDAyQS1BRTRCLUUwN0FFQUNGMTk0Rg&ctx=CiQ0OEQ4M0ExQi1GQTA3LTQwMkEtQUU0Qi1FMDdBRUFDRjE5NEYSAlVBGPY4INX-fCoMCAMQwIQ9GAMgwM8kONX-fEABOQ"],
            viewUndetermined: ["https://tk0x1.com/sj/tr?et=VAST_VIEW_UNDETERMINED&id=5d51644893aaead75ab169df&meta=MjA0NzgyOTo3Mjg2OjQ4RDgzQTFCLUZBMDctNDAyQS1BRTRCLUUwN0FFQUNGMTk0Rg&ctx=CiQ0OEQ4M0ExQi1GQTA3LTQwMkEtQUU0Qi1FMDdBRUFDRjE5NEYSAlVBGPY4INX-fCoMCAMQwIQ9GAMgwM8kONX-fEABOQ"]
        ),
        linear: LinearTracking(
            loaded: ["https://tk0x1.com/loaded"],
            start: ["https://tk0x1.com/sj/tr?et=VIDEO_STARTS&id=5d51644893aaead75ab169df&meta=MjA0NzgyOTo3Mjg2OjQ4RDgzQTFCLUZBMDctNDAyQS1BRTRCLUUwN0FFQUNGMTk0Rg&ctx=CiQ0OEQ4M0ExQi1GQTA3LTQwMkEtQUU0Qi1FMDdBRUFDRjE5NEYSAlVBGPY4INX-fCoMCAMQwIQ9GAMgwM8kONX-fEABOQ"],
            firstQuartile: ["https://tk0x1.com/sj/tr?et=VIDEO_25&id=5d51644893aaead75ab169df&meta=MjA0NzgyOTo3Mjg2OjQ4RDgzQTFCLUZBMDctNDAyQS1BRTRCLUUwN0FFQUNGMTk0Rg&ctx=CiQ0OEQ4M0ExQi1GQTA3LTQwMkEtQUU0Qi1FMDdBRUFDRjE5NEYSAlVBGPY4INX-fCoMCAMQwIQ9GAMgwM8kONX-fEABOQ"],
            midpoint: ["https://tk0x1.com/sj/tr?et=VIDEO_50&id=5d51644893aaead75ab169df&meta=MjA0NzgyOTo3Mjg2OjQ4RDgzQTFCLUZBMDctNDAyQS1BRTRCLUUwN0FFQUNGMTk0Rg&ctx=CiQ0OEQ4M0ExQi1GQTA3LTQwMkEtQUU0Qi1FMDdBRUFDRjE5NEYSAlVBGPY4INX-fCoMCAMQwIQ9GAMgwM8kONX-fEABOQ"],
            thirdQuartile: ["https://tk0x1.com/sj/tr?et=VIDEO_75&id=5d51644893aaead75ab169df&meta=MjA0NzgyOTo3Mjg2OjQ4RDgzQTFCLUZBMDctNDAyQS1BRTRCLUUwN0FFQUNGMTk0Rg&ctx=CiQ0OEQ4M0ExQi1GQTA3LTQwMkEtQUU0Qi1FMDdBRUFDRjE5NEYSAlVBGPY4INX-fCoMCAMQwIQ9GAMgwM8kONX-fEABOQ"],
            complete: ["https://tk0x1.com/sj/tr?et=VIDEO_COMPLETES&id=5d51644893aaead75ab169df&meta=MjA0NzgyOTo3Mjg2OjQ4RDgzQTFCLUZBMDctNDAyQS1BRTRCLUUwN0FFQUNGMTk0Rg&ctx=CiQ0OEQ4M0ExQi1GQTA3LTQwMkEtQUU0Qi1FMDdBRUFDRjE5NEYSAlVBGPY4INX-fCoMCAMQwIQ9GAMgwM8kONX-fEABOQ"],
            mute: ["https://tk0x1.com/sj/tr?et=VIDEO_MUTE&id=5d51644893aaead75ab169df&meta=MjA0NzgyOTo3Mjg2OjQ4RDgzQTFCLUZBMDctNDAyQS1BRTRCLUUwN0FFQUNGMTk0Rg&ctx=CiQ0OEQ4M0ExQi1GQTA3LTQwMkEtQUU0Qi1FMDdBRUFDRjE5NEYSAlVBGPY4INX-fCoMCAMQwIQ9GAMgwM8kONX-fEABOQ"],
            unmute: ["https://tk0x1.com/sj/tr?et=VIDEO_UNMUTE&id=5d51644893aaead75ab169df&meta=MjA0NzgyOTo3Mjg2OjQ4RDgzQTFCLUZBMDctNDAyQS1BRTRCLUUwN0FFQUNGMTk0Rg&ctx=CiQ0OEQ4M0ExQi1GQTA3LTQwMkEtQUU0Qi1FMDdBRUFDRjE5NEYSAlVBGPY4INX-fCoMCAMQwIQ9GAMgwM8kONX-fEABOQ"],
            pause: ["https://tk0x1.com/sj/tr?et=VIDEO_PAUSE&id=5d51644893aaead75ab169df&meta=MjA0NzgyOTo3Mjg2OjQ4RDgzQTFCLUZBMDctNDAyQS1BRTRCLUUwN0FFQUNGMTk0Rg&ctx=CiQ0OEQ4M0ExQi1GQTA3LTQwMkEtQUU0Qi1FMDdBRUFDRjE5NEYSAlVBGPY4INX-fCoMCAMQwIQ9GAMgwM8kONX-fEABOQ"],
            resume: ["https://tk0x1.com/sj/tr?et=VIDEO_RESUME&id=5d51644893aaead75ab169df&meta=MjA0NzgyOTo3Mjg2OjQ4RDgzQTFCLUZBMDctNDAyQS1BRTRCLUUwN0FFQUNGMTk0Rg&ctx=CiQ0OEQ4M0ExQi1GQTA3LTQwMkEtQUU0Qi1FMDdBRUFDRjE5NEYSAlVBGPY4INX-fCoMCAMQwIQ9GAMgwM8kONX-fEABOQ"],
            fullscreen: ["https://tk0x1.com/sj/tr?et=VIDEO_FULLSCREEN&id=5d51644893aaead75ab169df&meta=MjA0NzgyOTo3Mjg2OjQ4RDgzQTFCLUZBMDctNDAyQS1BRTRCLUUwN0FFQUNGMTk0Rg&ctx=CiQ0OEQ4M0ExQi1GQTA3LTQwMkEtQUU0Qi1FMDdBRUFDRjE5NEYSAlVBGPY4INX-fCoMCAMQwIQ9GAMgwM8kONX-fEABOQ"],
            exitFullscreen: ["https://tk0x1.com/sj/tr?et=VIDEO_EXIT_FULLSCREEN&id=5d51644893aaead75ab169df&meta=MjA0NzgyOTo3Mjg2OjQ4RDgzQTFCLUZBMDctNDAyQS1BRTRCLUUwN0FFQUNGMTk0Rg&ctx=CiQ0OEQ4M0ExQi1GQTA3LTQwMkEtQUU0Qi1FMDdBRUFDRjE5NEYSAlVBGPY4INX-fCoMCAMQwIQ9GAMgwM8kONX-fEABOQ"],
            skip: ["https://tk0x1.com/sj/tr?et=VIDEO_SKIP&id=5d51644893aaead75ab169df&meta=MjA0NzgyOTo3Mjg2OjQ4RDgzQTFCLUZBMDctNDAyQS1BRTRCLUUwN0FFQUNGMTk0Rg&ctx=CiQ0OEQ4M0ExQi1GQTA3LTQwMkEtQUU0Qi1FMDdBRUFDRjE5NEYSAlVBGPY4INX-fCoMCAMQwIQ9GAMgwM8kONX-fEABOQ&playtime=[CONTENTPLAYHEAD]"],
            close: ["https://tk0x1.com/sj/tr?et=AD_CLOSE&id=5d51644893aaead75ab169df&meta=MjA0NzgyOTo3Mjg2OjQ4RDgzQTFCLUZBMDctNDAyQS1BRTRCLUUwN0FFQUNGMTk0Rg&ctx=CiQ0OEQ4M0ExQi1GQTA3LTQwMkEtQUU0Qi1FMDdBRUFDRjE5NEYSAlVBGPY4INX-fCoMCAMQwIQ9GAMgwM8kONX-fEABOQ&playtime=[CONTENTPLAYHEAD]"],
            expand: ["https://tk0x1.com/playerExpand"],
            collapse: ["https://tk0x1.com/playerCollapse"],
            click: ["https://clicktracking"],
            companionClick: ["https://loopmeedge.net/companionClickTracking"],
            progress: [
                ProgressEvent(
                    link: "https://tk0x1.com/sj/tr?et=VIDEO_5SEC&id=5d51644893aaead75ab169df&meta=MjA0NzgyOTo3Mjg2OjQ4RDgzQTFCLUZBMDctNDAyQS1BRTRCLUUwN0FFQUNGMTk0Rg&ctx=CiQ0OEQ4M0ExQi1GQTA3LTQwMkEtQUU0Qi1FMDdBRUFDRjE5NEYSAlVBGPY4INX-fCoMCAMQwIQ9GAMgwM8kONX-fEABOQ",
                    offset: 5),
                ProgressEvent(
                    link: "https://tk0x1.com/sj/tr?et=VIDEO_10SEC&id=5d51644893aaead75ab169df&meta=MjA0NzgyOTo3Mjg2OjQ4RDgzQTFCLUZBMDctNDAyQS1BRTRCLUUwN0FFQUNGMTk0Rg&ctx=CiQ0OEQ4M0ExQi1GQTA3LTQwMkEtQUU0Qi1FMDdBRUFDRjE5NEYSAlVBGPY4INX-fCoMCAMQwIQ9GAMgwM8kONX-fEABOQ",
                    offset: 10),
                ProgressEvent(
                    link: "https://tk0x1.com/sj/tr?et=VIDEO_15SEC&id=5d51644893aaead75ab169df&meta=MjA0NzgyOTo3Mjg2OjQ4RDgzQTFCLUZBMDctNDAyQS1BRTRCLUUwN0FFQUNGMTk0Rg&ctx=CiQ0OEQ4M0ExQi1GQTA3LTQwMkEtQUU0Qi1FMDdBRUFDRjE5NEYSAlVBGPY4INX-fCoMCAMQwIQ9GAMgwM8kONX-fEABOQ",
                    offset: 15
                )
            ])
    )
    
    let expectedAssetsLinks = AssetLinks(
        videoURL: ["https://loopmeedge.net/encodings/2011821/153728e8-a752-3d6c-dbc2-bc7e425253b6.mp4"],
        vpaidURL: "",
        adParameters: "{ \"foo\" : \"bar\" }",
        endCard: ["https://loopmeedge.net/assets/2011821/cd02f974-fdae-9211-9d6a-4c5f78e236a1.jpg"]
    )
    
    
    let expectedLoopMeOmid = AdVerification(
        vendor: "loopme.com-omid",
        jsResource: "https://i.loopme.me/html/omid/omid.js",
        verificationParameters: "{\"measurable\":\"https://tk0x1.com/sj/tr?et=MEASURABLE&meta=MjA0NzgyOTo3Mjg2OjQ4RDgzQTFCLUZBMDctNDAyQS1BRTRCLUUwN0FFQUNGMTk0Rg&ctx=CiQ0OEQ4M0ExQi1GQTA3LTQwMkEtQUU0Qi1FMDdBRUFDRjE5NEYSAlVBGPY4INX-fCoMCAMQwIQ9GAMgwM8kONX-fEABOQ&id=5d51644893aaead75ab169df&omid=1\", \"viewable\":\"https://tk0x1.com/sj/tr?et=AD_VIEWABLE&meta=MjA0NzgyOTo3Mjg2OjQ4RDgzQTFCLUZBMDctNDAyQS1BRTRCLUUwN0FFQUNGMTk0Rg&ctx=CiQ0OEQ4M0ExQi1GQTA3LTQwMkEtQUU0Qi1FMDdBRUFDRjE5NEYSAlVBGPY4INX-fCoMCAMQwIQ9GAMgwM8kONX-fEABOQ&id=5d51644893aaead75ab169df&omid=1\" }"
    )
    
    let expectedLoopMeOmid2 = AdVerification(
        vendor: "loopme.com-omid",
        jsResource: "https://i.loopme.me/html/omid/omid.js",
        verificationParameters: "{\"measurable\":\"https://tk0x1.com/sj/tr?et=MEASURABLE&meta=MjA1NDI1Nzo2OTg1MjQ6MzAxNTE0ZDItOTNlMC00OGRhLWI5NTktOGRiYWM4MGQ3OTI3&ctx=CiQzMDE1MTRkMi05M2UwLTQ4ZGEtYjk1OS04ZGJhYzgwZDc5MjcSAlVBGJzRKiDxsH0qBwgDGAEg6Ac48bB9QAHa&id=5d8df5ce1f9fb0e4624ec0d3&omid=1\", \"viewable\":\"https://tk0x1.com/sj/tr?et=AD_VIEWABLE&meta=MjA1NDI1Nzo2OTg1MjQ6MzAxNTE0ZDItOTNlMC00OGRhLWI5NTktOGRiYWM4MGQ3OTI3&ctx=CiQzMDE1MTRkMi05M2UwLTQ4ZGEtYjk1OS04ZGJhYzgwZDc5MjcSAlVBGJzRKiDxsH0qBwgDGAEg6Ac48bB9QAHa&id=5d8df5ce1f9fb0e4624ec0d3&omid=1\"}"
    )
    
    let expectedMoatOmid = AdVerification(
        vendor: "moat.com-omsdkloopme332977896616",
        jsResource: "https://z.moatads.com/omsdkloopme332977896616/moatvideo.js",
        verificationParameters: "{\"moatClientLevel1\":\"B_and_J\",\"moatClientLevel2\":\"B_and_J_Dough_Cores\",\"moatClientLevel3\":\"%%LI_NAME%%\",\"moatClientLevel4\":\"VAST_-_Phone_-_Pre-Roll_-_Behavioral_-_Inapp\",\"moatClientSlicer1\":\"com.king.farmheroessaga_721460\",\"moatClientSlicer2\":\"VAST\"}"
    )
    
    var adResponse: String?
    var adResponseWrapper: String?
    
    var vastProperties: VastProperties?
    var vastPropertiesWrapper: VastProperties?

    func prepareVastProperties(fileName: String) -> VastProperties? {
        if let path = Bundle(for: type(of: self)).path(forResource: fileName, ofType: "xml", inDirectory: nil) {
            let vastString = try? String(contentsOfFile: path)
            guard let data = vastString?.data(using: .utf8) else {
                return nil
            }
            return VastProperties(data: data)
        }
        
        return nil
    }
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.vastProperties = prepareVastProperties(fileName: "VAST")
        self.vastPropertiesWrapper = prepareVastProperties(fileName: "VASTWrapper")
    }
    
    func testVastProperties() {
        XCTAssertEqual(vastProperties?.trackingLinks, expectedAdTracking)
        XCTAssertEqual(vastProperties?.trackingLinks.linear, expectedAdTracking.linear)
        XCTAssertEqual(vastProperties?.trackingLinks.viewableImpression, expectedAdTracking.viewableImpression)

        XCTAssertEqual(vastProperties?.assetLinks, expectedAssetsLinks)
        XCTAssertEqual(vastProperties?.assetLinks.adParameters, "{ \"foo\" : \"bar\" }")
        XCTAssertEqual(vastProperties?.adVerifications, [expectedLoopMeOmid])
        XCTAssertEqual(vastProperties?.duration, 30.0)
        XCTAssertEqual(vastProperties?.skipOffset, VastSkipOffset(type: .seconds, value: 8))
    }
    
    func testVastPropertiesWrapper() {
        XCTAssertEqual(vastPropertiesWrapper?.adVerifications, [expectedMoatOmid, expectedLoopMeOmid2])
        XCTAssertEqual(
            vastPropertiesWrapper?.adTagURI,
            "https://raw.githubusercontent.com/InteractiveAdvertisingBureau/VAST_Samples/master/VAST%203.0%20Samples/Inline_Companion_Tag-test.xml"
        )
    }
}
