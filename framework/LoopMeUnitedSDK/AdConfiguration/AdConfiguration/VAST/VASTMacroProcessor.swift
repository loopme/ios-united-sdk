//
//  VASTMacroProcessor.swift
//  LoopMeServerCommuniator
//
//  Created by Bohdan on 8/27/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

import Foundation

struct VASTMacroProcessor {
    static func macroExpandedURL(for url: URL, errorCode: Int) -> URL? {
        return self.macroExpandedURL(for: url, errorCode: errorCode, videoTimeOffset: -1, videoAssetURL: nil)
    }
    
    static func macroExpandedURL(for url: URL, errorCode: Int, videoTimeOffset: TimeInterval, videoAssetURL: URL?) -> URL? {
        
        var urlString = url.absoluteString
        let stringErrorCode = "\(errorCode)".trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !stringErrorCode.isEmpty {
            urlString = urlString.replacingOccurrences(of: "[ERRORCODE]", with: stringErrorCode)
            urlString = urlString.replacingOccurrences(of: "%5BERRORCODE%5D", with: stringErrorCode)
            urlString = urlString.replacingOccurrences(of: "[REASON]", with: stringErrorCode)
            urlString = urlString.replacingOccurrences(of: "%5BREASON%5D", with: stringErrorCode)
        }
        
        if videoTimeOffset >= 0 {
            let timeOffsetString = string(from: videoTimeOffset)
            urlString = urlString.replacingOccurrences(of: "[CONTENTPLAYHEAD]", with: timeOffsetString)
            urlString = urlString.replacingOccurrences(of: "5BCONTENTPLAYHEAD%5D", with: timeOffsetString)
        }
        
        if videoAssetURL != nil {
            if let encodedAssetURLString = videoAssetURL?.absoluteString.addingPercentEncodingForRFC3986() {
                urlString = urlString.replacingOccurrences(of: "[ASSETURI]", with: encodedAssetURLString)
                urlString = urlString.replacingOccurrences(of: "%5BASSETURI%5D", with: encodedAssetURLString)
            }
        }
        
        let cachebuster = "\(Int.random(in: 90000000...100000000))"
        
        urlString = urlString.replacingOccurrences(of: "[CACHEBUSTING]", with: cachebuster)
        urlString = urlString.replacingOccurrences(of: "%5BCACHEBUSTING%5D", with: cachebuster)
        
        let timestampString = timeStampISO8601String()
        
        urlString = urlString.replacingOccurrences(of: "[TIMESTAMP]", with: timestampString)
        urlString = urlString.replacingOccurrences(of: "%5BTIMESTAMP%5D", with: timestampString)
        
        return URL(string: urlString)
            
    }
    
    private static func string(from timeInterval: TimeInterval) -> String {
        if timeInterval < 0 {
            return "00:00:00.000"
        }
        
        let flooredTimeInterval = Int(timeInterval)
        let hours = flooredTimeInterval / 3600
        let minutes = (flooredTimeInterval / 60) % 60
        let seconds = flooredTimeInterval % 60
        let ms = Int((timeInterval.truncatingRemainder(dividingBy: 1)) * 1000)
        
        return String(format: "%0.2d:%0.2d:%0.2d.%0.3d",hours,minutes,seconds,ms)
    }

    static func timeStampISO8601String() -> String {
        let dateFormatter = DateFormatter()
        let enUSPOSIXLocale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = enUSPOSIXLocale
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let now = Date()
        let iso8601String = dateFormatter.string(from: now)
        return iso8601String
    }
    
}
