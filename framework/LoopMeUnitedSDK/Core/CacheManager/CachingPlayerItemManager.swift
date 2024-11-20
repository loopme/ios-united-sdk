//
//  CachingPlayerItemManager.swift
//  LoopMeUnitedSDK
//
//  Created by Valerii Roman on 15/11/2024.
//

import Foundation

@objcMembers public class CachingPlayerItemCacheManager: NSObject {
    public let cacheExpirationInterval: TimeInterval = 32 * 60 * 60 // 32 hours
    public let maxCacheSize: UInt64 = 50 * 1024 * 1024 // 50 MB
    
    public let accessQueue: DispatchQueue
    
    public override init() {
        self.accessQueue = DispatchQueue(label: "com.yourapp.CachingPlayerItemCacheManagerQueue")
        super.init()
        cleanCache()
    }
    
    public func defaultCacheDirectory() -> URL {
        let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let cacheDir = cacheDirectory.appendingPathComponent("lm_assets", isDirectory: true)
        return cacheDir
    }
    
    public func cacheFileURL(forKey key: String, url: URL) -> URL {
        let fileName = "\(key).\(url.pathExtension)"
        return defaultCacheDirectory().appendingPathComponent(fileName)
    }
    
    public func cacheProgressFileURL(forKey key: String, url: URL) -> URL {
        let fileName = "\(key)_caching.\(url.pathExtension)"
        return defaultCacheDirectory().appendingPathComponent(fileName)
    }
    
    public func cleanCache() {
        accessQueue.async {
            self.ensureCacheDirectoryExists()
            self.clearExpiredCacheFiles()
            self.enforceMaxCacheSize()
        }
    }
    
    private func ensureCacheDirectoryExists() {
        let cacheDirectory = defaultCacheDirectory()
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
        let cacheDirectory = defaultCacheDirectory()
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
        let cacheDirectory = defaultCacheDirectory()
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
}
