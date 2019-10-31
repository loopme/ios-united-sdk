//
//  MRAIDExpandProperties.swift
//  AdConfiguration
//
//  Created by Bohdan on 9/18/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

import Foundation

struct MRAIDExpandProperties {
    static let empty = MRAIDExpandProperties(width: 0, height: 0, useCustomClose: false)

    var width: Float
    var height: Float
    var useCustomClose: Bool
}
