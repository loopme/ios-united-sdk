//
//  CachingPlayerItemWrapper.swift
//  LoopMeUnitedSDK
//
//  Created by Valerii Roman on 13/11/2024.
//

import Foundation
import AVFoundation

@objc public protocol CachingPlayerItemWrapperDelegate: NSObjectProtocol {
    @objc optional func playerItemReadyToPlay(_ playerItem: CachingPlayerItemWrapper)
    @objc optional func playerItemDidFailToPlay(_ playerItem: CachingPlayerItemWrapper, error: Error?)
    @objc optional func playerItemPlaybackStalled(_ playerItem: CachingPlayerItemWrapper)
    @objc optional func playerItem(_ playerItem: CachingPlayerItemWrapper, didFinishDownloadingToURL location: URL)
    @objc optional func playerItem(_ playerItem: CachingPlayerItemWrapper, didDownloadBytesSoFar bytesDownloaded: Int64, outOf bytesExpected: Int64)
    @objc optional func playerItem(_ playerItem: CachingPlayerItemWrapper, downloadingFailedWith error: Error)
}

@objc public class CachingPlayerItemWrapper: NSObject, CachingPlayerItemDelegate {
     var cachingPlayerItem: CachingPlayerItem?
    @objc public weak var delegate: CachingPlayerItemWrapperDelegate?
    
    
    @objc public init(url: URL, cacheKey: String) {
        super.init()
        
        let cacheManager = CachingPlayerItemCacheManager()
        let cacheFileURL = cacheManager.cacheFileURL(forKey: cacheKey, url: url)
        let cacheProgressFileURL = cacheManager.cacheProgressFileURL(forKey: cacheKey, url: url)
        
            //Check if caching in progress
        if FileManager.default.fileExists(atPath: cacheProgressFileURL.path) {
            cachingPlayerItem = CachingPlayerItem(nonCachingURL: cacheFileURL)
        } else if FileManager.default.fileExists(atPath: cacheFileURL.path) {
            cachingPlayerItem = CachingPlayerItem(filePathURL: cacheFileURL)
        } else {
            // Load url and put the path for caching
            cachingPlayerItem = CachingPlayerItem(url: url, saveFilePath: cacheProgressFileURL.path, customFileExtension: url.pathExtension)
        }
        
        cachingPlayerItem?.delegate = self
    }
    
    @objc public var avPlayerItem: AVPlayerItem? {
        return cachingPlayerItem
    }
    
    // MARK: - CachingPlayerItemDelegate Methods
    
    public func playerItemReadyToPlay(_ playerItem: CachingPlayerItem) {
        delegate?.playerItemReadyToPlay?(self)
    }
    
    public func playerItemDidFailToPlay(_ playerItem: CachingPlayerItem, withError error: Error?) {
        delegate?.playerItemDidFailToPlay?(self, error: error)
    }
    
    public func playerItemPlaybackStalled(_ playerItem: CachingPlayerItem) {
        delegate?.playerItemPlaybackStalled?(self)
    }
    
    public func playerItem(_ playerItem: CachingPlayerItem, didFinishDownloadingFileAt filePath: String) {
        do {
            let srcURL = URL(fileURLWithPath: filePath)
            let dstURL = URL(fileURLWithPath: filePath.replacingOccurrences(of: "_caching", with: ""))
            try FileManager.default.moveItem(at: srcURL, to: dstURL)
            delegate?.playerItem?(self, didFinishDownloadingToURL: dstURL)
        } catch {
            print("Error - can't replace the path: \(error.localizedDescription)")
        }
    }
    
    public func playerItem(_ playerItem: CachingPlayerItem, didDownloadBytesSoFar bytesDownloaded: Int, outOf bytesExpected: Int) {
        delegate?.playerItem?(self, didDownloadBytesSoFar: Int64(bytesDownloaded), outOf: Int64(bytesExpected))
    }
    
    public func playerItem(_ playerItem: CachingPlayerItem, downloadingFailedWith error: Error) {
        delegate?.playerItem?(self, downloadingFailedWith: error)
    }
}
