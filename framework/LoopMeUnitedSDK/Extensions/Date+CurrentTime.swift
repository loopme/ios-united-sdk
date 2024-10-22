//
//  Date+CurrentTime.swift
//  LoopMeUnitedSDK
//
//  Created by Lukasz Tomaszewski on 22/10/2024.
//

import Foundation

@objc public extension NSDate {
    
    @objc class func currentFormattedTime() -> String {
        let currentDate = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"

        let formattedDateString = dateFormatter.string(from: currentDate)
        
        return formattedDateString
    }
}
