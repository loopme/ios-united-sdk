//
//  String+Extension.swift
//  LoopMeUnitedSDK
//
//  Created by Valerii Roman on 04/07/2024.
//  Copyright © 2024 LoopMe. All rights reserved.
//

import Foundation
extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
    
    func addingPercentEncodingForRFC3986() -> String? {
        let unreserved = ":-._~/?"
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: unreserved)
        return self.addingPercentEncoding(withAllowedCharacters: allowed)
    }
    
    var numberValue:NSNumber? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.number(from: self)
    }
}
