//
//  CachingPlayerItemTests.swift
//  LoopMeUnitedSDKTests
//
//  Created by Valerii Roman on 18/11/2024.
//  Copyright © 2024 LoopMe. All rights reserved.
//

import XCTest
import LoopMeUnitedSDK

class MockCachingPlayerItemWrapperDelegate: NSObject, CachingPlayerItemWrapperDelegate {
    
    var readyToPlayCalled = false
    var didFailToPlayCalled = false
    var playbackStalledCalled = false
    var didFinishDownloadingCalled = false
    var didDownloadBytesCalled = false
    var downloadingFailedCalled = false
    
    var downloadedURL: URL?
    var downloadError: Error?
    var bytesDownloaded: Int64 = 0
    var bytesExpected: Int64 = 0
    
    func playerItemReadyToPlay(_ playerItemWrapper: CachingPlayerItemWrapper) {
        readyToPlayCalled = true
    }
    
    func playerItemDidFailToPlay(_ playerItemWrapper: CachingPlayerItemWrapper, error: Error?) {
        didFailToPlayCalled = true
        downloadError = error
    }
    
    func playerItemPlaybackStalled(_ playerItemWrapper: CachingPlayerItemWrapper) {
        playbackStalledCalled = true
    }
    
    func playerItem(_ playerItemWrapper: CachingPlayerItemWrapper, didFinishDownloadingToURL location: URL) {
        didFinishDownloadingCalled = true
        downloadedURL = location
    }
    
    func playerItem(_ playerItemWrapper: CachingPlayerItemWrapper, didDownloadBytesSoFar bytesDownloaded: Int64, outOf bytesExpected: Int64) {
        didDownloadBytesCalled = true
        self.bytesDownloaded = bytesDownloaded
        self.bytesExpected = bytesExpected
    }
    
    func playerItem(_ playerItemWrapper: CachingPlayerItemWrapper, downloadingFailedWith error: Error) {
        downloadingFailedCalled = true
        downloadError = error
    }
}

class CachingPlayerItemTests: XCTestCase {
    
    var cacheManager: CachingPlayerItemCacheManager!
    var tempCacheDirectory: URL!
    
    override func setUp() {
        super.setUp()
        
        let tempDirectory = FileManager.default.temporaryDirectory
        tempCacheDirectory = tempDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        
        cacheManager = CachingPlayerItemCacheManager()
        
        do {
            try FileManager.default.createDirectory(at: tempCacheDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            XCTFail("Failed to create temporary cache directory: \(error.localizedDescription)")
        }
    }
    
    override func tearDown() {
        super.tearDown()
        
        do {
            try FileManager.default.removeItem(at: tempCacheDirectory)
        } catch {
            print("Error removing temporary cache directory: \(error.localizedDescription)")
        }
        
        cacheManager = nil
    }
    
    func testInitialization() {
        XCTAssertNotNil(cacheManager, "Cache manager should not be nil after initialization.")
        
        let sampleURL = URL(string: "https://example.com/video.mp4")!
        let cacheKey = "test_video"
        
        let wrapper = CachingPlayerItemWrapper(url: sampleURL, cacheKey: cacheKey)
        XCTAssertNotNil(wrapper, "CachingPlayerItemWrapper should not be nil after initialization.")
        
        XCTAssertNotNil(wrapper.avPlayerItem, "AVPlayerItem should not be nil in the wrapper.")
    }
    
    func testCacheFileURLGeneration() {
        let sampleURL = URL(string: "https://loopmeedge.net/assets/2136047/portrait_1728270613721.mp4")!
        let cacheKey = "test_video"
        
        let cacheFileURL = cacheManager.cacheFileURL(forKey: cacheKey, url: sampleURL)
        let expectedFileName = "\(cacheKey).mp4"
        let expectedURL = cacheManager.defaultCacheDirectory().appendingPathComponent(expectedFileName)
        
        XCTAssertEqual(cacheFileURL, expectedURL, "Cache file URL should match the expected URL.")
        
        let cacheProgressFileURL = cacheManager.cacheProgressFileURL(forKey: cacheKey, url: sampleURL)
        let expectedProgressFileName = "\(cacheKey)_caching.mp4"
        let expectedProgressURL = cacheManager.defaultCacheDirectory().appendingPathComponent(expectedProgressFileName)
        
        XCTAssertEqual(cacheProgressFileURL, expectedProgressURL, "Cache progress file URL should match the expected URL.")
    }
}
