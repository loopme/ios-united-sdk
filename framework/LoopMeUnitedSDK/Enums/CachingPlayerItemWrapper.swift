//
//  CachingPlayerItemWrapper.swift
//  LoopMeUnitedSDK
//
//  Created by Valerii Roman on 13/11/2024.
//

import Foundation
import AVFoundation
import CachingPlayerItem

@objc public protocol CachingPlayerItemWrapperDelegate: NSObjectProtocol {
    @objc optional func playerItemReadyToPlay(_ playerItem: CachingPlayerItemWrapper)
    @objc optional func playerItemDidFailToPlay(_ playerItem: CachingPlayerItemWrapper, error: Error?)
    @objc optional func playerItemPlaybackStalled(_ playerItem: CachingPlayerItemWrapper)
    @objc optional func playerItem(_ playerItem: CachingPlayerItemWrapper, didFinishDownloadingToURL location: URL)
    @objc optional func playerItem(_ playerItem: CachingPlayerItemWrapper, didDownloadBytesSoFar bytesDownloaded: Int64, outOf bytesExpected: Int64)
    @objc optional func playerItem(_ playerItem: CachingPlayerItemWrapper, downloadingFailedWith error: Error)
}

@objc public class CachingPlayerItemWrapper: NSObject, CachingPlayerItemDelegate {
    private var cachingPlayerItem: CachingPlayerItem?
    @objc public weak var delegate: CachingPlayerItemWrapperDelegate?
    private  let cacheExpirationInterval: TimeInterval = 32 * 60 * 60 // 32 hours
    private  let maxCacheSize: UInt64 = 50 * 1024 * 1024 // 50 MB
    private lazy var cacheDirectory: URL = self.defaultCacheDirectory()
    private var lock = NSLock()

    
    @objc public init(url: URL, cacheKey: String) {
        super.init()
        lock.lock()
        self.cleanCache()
        let cacheFileURL = self.cacheFileURL(forKey: cacheKey, url: url)
        let cacheProgressFileURL = self.cacheFileURL(forKey: cacheKey + "_caching", url: url)

            // File in caching process
        if FileManager.default.fileExists(atPath: cacheProgressFileURL.path) {
            cachingPlayerItem = CachingPlayerItem(nonCachingURL: cacheFileURL)
        } else if FileManager.default.fileExists(atPath: cacheFileURL.path) {
            // Cached file exists
            cachingPlayerItem = CachingPlayerItem(filePathURL: cacheFileURL)
        } else {
            // Cached file doesn't exist
            cachingPlayerItem = CachingPlayerItem(url: url, saveFilePath: cacheProgressFileURL.path, customFileExtension: url.pathExtension)
        }
        lock.unlock()
        cachingPlayerItem?.delegate = self
    }
    
    @objc public var avPlayerItem: AVPlayerItem? {
        return cachingPlayerItem
    }
    
    // MARK: - Cache Management Methods
    
    @objc public func defaultCacheDirectory() -> URL {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let cacheDir = cacheDirectory.appendingPathComponent("lm_assets", isDirectory: true)
        return cacheDir
    }
    
    @objc public func cacheFileURL(forKey key: String, url: URL) -> URL {
        let fileName = "\(key).\(url.pathExtension)"
        return cacheDirectory.appendingPathComponent(fileName)
    }
    
    @objc public func cleanCache() {
        DispatchQueue.global(qos: .background).async {
            self.ensureCacheDirectoryExists()
            self.clearExpiredCacheFiles()
            self.enforceMaxCacheSize()
        }
    }
    
    private func ensureCacheDirectoryExists() {
        if !FileManager.default.fileExists(atPath: cacheDirectory.path) {
            do {
                try FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating cache directory: \(error.localizedDescription)")
            }
        }
    }
    
    private func clearExpiredCacheFiles() {
        let expirationDate = Date().addingTimeInterval(-cacheExpirationInterval)
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles)
            for fileURL in fileURLs {
                if let creationDate = try fileURL.resourceValues(forKeys: [.creationDateKey]).creationDate, creationDate < expirationDate {
                    try FileManager.default.removeItem(at: fileURL)
                }
            }
        } catch {
            print("Error clearing expired cache files: \(error.localizedDescription)")
        }
    }
    
    private func enforceMaxCacheSize() {
        do {
            var cacheSize: UInt64 = 0
            var fileInfos: [(url: URL, accessDate: Date, size: UInt64)] = []
            
            let fileURLs = try FileManager.default.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: [.contentAccessDateKey, .fileSizeKey], options: .skipsHiddenFiles)
            
            for fileURL in fileURLs {
                let resourceValues = try fileURL.resourceValues(forKeys: [.contentAccessDateKey, .fileSizeKey])
                if let fileSize = resourceValues.fileSize, let accessDate = resourceValues.contentAccessDate {
                    let fileSizeUInt64 = UInt64(fileSize)
                    cacheSize += fileSizeUInt64
                    fileInfos.append((url: fileURL, accessDate: accessDate, size: fileSizeUInt64))
                }
            }
            
            // If cache size exceeds the max, delete oldest files
            if cacheSize > maxCacheSize {
                // Sort files by last access date (oldest first)
                fileInfos.sort { $0.accessDate < $1.accessDate }
                
                for fileInfo in fileInfos {
                    if cacheSize <= maxCacheSize {
                        break
                    }
                    try FileManager.default.removeItem(at: fileInfo.url)
                    cacheSize -= fileInfo.size
                }
            }
        } catch {
            print("Error enforcing max cache size: \(error.localizedDescription)")
        }
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
            print("Error - can't replace the path")
        }
        
    }
    
    public func playerItem(_ playerItem: CachingPlayerItem, didDownloadBytesSoFar bytesDownloaded: Int, outOf bytesExpected: Int) {
        delegate?.playerItem?(self, didDownloadBytesSoFar: Int64(bytesDownloaded), outOf: Int64(bytesExpected))
    }
    
    public func playerItem(_ playerItem: CachingPlayerItem, downloadingFailedWith error: Error) {
        delegate?.playerItem?(self, downloadingFailedWith: error)
    }
}
