//
//  VastSkipOffset.swift
//  LoopMeServerCommuniator
//
//  Created by Bohdan on 8/29/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

import Foundation

@objc (LoopMeTimeOffsetType)
public enum TimeOffsetType: Int {
    case percent
    case seconds
}

 public struct VastSkipOffset: Equatable {
    
    public static func == (lhs: VastSkipOffset, rhs: VastSkipOffset) -> Bool {
        return lhs.type == rhs.type && lhs.value == rhs.value
    }
    
    static let empty = VastSkipOffset(type: .seconds, value: 0)
    static let seconds30 = VastSkipOffset(type: .seconds, value: 30)
    static let seconds5 = VastSkipOffset(type: .seconds, value: 5)
    static let notExist = VastSkipOffset(type: .percent, value: 100)
    
    var type: TimeOffsetType
    var value: Double
}
