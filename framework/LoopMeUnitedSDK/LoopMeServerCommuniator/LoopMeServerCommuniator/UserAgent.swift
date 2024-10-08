//
//  UserAgent.swift
//  LoopMeSDK
//
//  Created by Bohdan on 10/8/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

import Foundation
import UIKit

public class UserAgent: NSObject {
    private static var defaults = UserDefaults.standard

    private static func clientUserAgent(prefix: String) -> String {
        let userAgent = "\(prefix) (\(device); \(OS) \(OSVersionUnderlined) like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/\(safariVersion) Mobile/15E148 Safari/604.1"
        return userAgent
    }
    
    private static var OSVersionUnderlined: String {
        UIDevice.current.systemVersion.replacingOccurrences(of: ".", with: "_")
    }
    
    private static var safariVersion: String {
        guard let version = UIDevice.current.systemVersion.split(separator: ".").first,
        let versionNum = Int(version) else { return "13.0.1"}
        
        switch versionNum {
        case 11:
            return "11.0"
        case 12:
            return "12.1.2"
        case 13:
            return "13.0.1"
        default:
            return "13.0.1"
        }
    }
    
    private static var device: String {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return "iPhone"
        } else if UIDevice.current.userInterfaceIdiom == .pad {
            return "iPad"
        }
        return "unspecified"
    }
    
    private static var OS: String {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return "CPU iPhone OS"
        }
        return "CPU iPhone"
    }

    @objc public static var defaultUserAgent: String {
        clientUserAgent(prefix: "Mozilla/5.0")
    }
    
    @objc public static func formattedDateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.string(from: date)
    }
}
