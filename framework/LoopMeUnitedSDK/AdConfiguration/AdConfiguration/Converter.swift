//
//  Converter.swift
//  LoopMeServerCommuniator
//
//  Created by Bohdan on 8/14/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

import Foundation

struct Converter {
    static func timeInterval(from string: String) -> TimeInterval {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        formatter.dateFormat = "HH:mm:ss"
        guard let date = formatter.date(from: string) else { return 0 }
        return TimeInterval(calendar.component(.second, from: date))
    }
}
