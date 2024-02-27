//
//  Converter.swift
//  LoopMeServerCommuniator
//
//  Created by Bohdan on 8/14/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

import Foundation

struct Converter {
    
    /// Takes only seconds component from "HH:mm:ss" (ISO8601) formatted string or returns 0 if string not formatted properly
    /// - Parameter string: "HH:mm:ss" ISO8601 formatted string
    /// - Returns: seconds
    static func timeInterval(from string: String) -> TimeInterval {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        guard let date = formatter.date(from: string) else { return 0 }
        return TimeInterval(Calendar.current.component(.second, from: date))
    }
}
