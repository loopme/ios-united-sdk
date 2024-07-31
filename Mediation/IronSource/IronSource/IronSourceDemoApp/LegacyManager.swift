//
//  LegacyManager.swift
//  IronSourceDemoApp
//
//  Created by Valerii Roman on 29/07/2024.
//

import UIKit

@objc public class TimeDifference: NSObject {
    @objc public var min: NSNumber
    @objc public var max: NSNumber

    @objc public init(min: NSNumber, max: NSNumber) {
        self.min = min
        self.max = max
    }
}

@objc public class LegacyManger: NSObject {

    @objc public static let shared = LegacyManger()

    private var logDictionary: [NSNumber: [String: NSNumber]] = [:]
    private var currentCallCount: NSNumber = 0
    private var adType: String = ""

    private override init() {
        super.init()
    }

    @objc public func logEvent(forCall callCount: NSNumber?, withText text: String, adType: String?) {
        if let callCount = callCount {
            self.currentCallCount = callCount
        }
        
        let currentTimestamp = CFAbsoluteTimeGetCurrent() as NSNumber
        if let adType = adType {
            self.adType = adType
        }
        let event = "\(self.adType) \(text)"
        let logEntry = [event: currentTimestamp]
        
        if var existingEntries = logDictionary[currentCallCount] {
            existingEntries.merge(logEntry) { (_, new) in new }
            logDictionary[currentCallCount] = existingEntries
        } else {
            logDictionary[currentCallCount] = logEntry
        }
        
        NSLog("Log Event  - Call \(currentCallCount): \(logEntry)")
    }

    @objc public func getLogDictionary() -> [NSNumber: [String: NSNumber]] {
        return logDictionary
    }

    @objc public func minMaxTimeDifferences() -> [NSString: TimeDifference]? {
        var result: [NSString: TimeDifference] = [
            "Adapter": TimeDifference(min: NSNumber(value: TimeInterval.greatestFiniteMagnitude), max: NSNumber(value: 0.0)),
            "App": TimeDifference(min: NSNumber(value: TimeInterval.greatestFiniteMagnitude), max: NSNumber(value: 0.0)),
            "SDK": TimeDifference(min: NSNumber(value: TimeInterval.greatestFiniteMagnitude), max: NSNumber(value: 0.0))
        ]
        
        let eventPairs: [(String, String, String)] = [
            ("Banner Load (Adapter)", "Banner Did Load (Adapter)", "Adapter"),
            ("Banner Load (App)", "Banner Did Load (App)", "App"),
            ("Banner Load (SDK)", "Banner Did Load (SDK)", "SDK"),
            ("Rewarded Load (Adapter)", "Rewarded Did Load (Adapter)", "Adapter"),
            ("Rewarded Load (App)", "Rewarded Did Load (App)", "App"),
            ("Rewarded Load (SDK)", "Rewarded Did Load (SDK)", "SDK"),
            ("Interstitial Load (Adapter)", "Interstitial Did Load (Adapter)", "Adapter"),
            ("Interstitial Load (App)", "Interstitial Did Load (App)", "App"),
            ("Interstitial Load (SDK)", "Interstitial Did Load (SDK)", "SDK") // Corrected this line
        ]
        
        for (_, events) in logDictionary {
            for (startEvent, endEvent, category) in eventPairs {
                if let startTime = events[startEvent], let endTime = events[endEvent] {
                    let diff = endTime.doubleValue - startTime.doubleValue
                    let diffNSNumber = NSNumber(value: diff)
                    if diff < result[category as NSString]!.min.doubleValue {
                        result[category as NSString]!.min = diffNSNumber
                    }
                    if diff > result[category as NSString]!.max.doubleValue {
                        result[category as NSString]!.max = diffNSNumber
                    }
                }
            }
        }
        
        for (category, diffs) in result {
            if diffs.min.doubleValue == TimeInterval.greatestFiniteMagnitude {
                result[category] = nil
            }
        }
        
        return result.filter { $0.value != nil }
    }
    
    
    @objc public func cleanLogDictionary() {
        self.logDictionary = [:]
    }
    
    @objc public func logDictionaryToCSV() -> String {
        var headers: [String] = ["Call Count"]
         var csvData: [NSNumber: [String: String]] = [:]

         // Gather all unique event names for headers
         for (_, events) in logDictionary {
             for (event, _) in events {
                 if !headers.contains(event) {
                     headers.append(event)
                 }
             }
         }

         // Prepare the data for CSV
         for (callCount, events) in logDictionary {
             var row: [String: String] = [:]
             row["Call Count"] = "\(callCount)"
             for event in headers where event != "Call Count" {
                 // Convert NSNumber to String if present
                 row[event] = events[event]?.stringValue ?? ""
             }
             csvData[callCount] = row
         }

         // Create CSV string from headers and data
         var csvString = headers.joined(separator: ",") + "\n"
         for callCount in csvData.keys.sorted(by: { $0.intValue < $1.intValue }) {
             if let row = csvData[callCount] {
                 let rowValues = headers.map { row[$0] ?? "" }
                 csvString.append(rowValues.joined(separator: ",") + "\n")
             }
         }

         return csvString
    }
    
}
