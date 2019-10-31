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

public struct VastSkipOffset {
    
    static let empty = VastSkipOffset(type: .seconds, value: 0)
    
    var type: TimeOffsetType
    var value: Double
}
