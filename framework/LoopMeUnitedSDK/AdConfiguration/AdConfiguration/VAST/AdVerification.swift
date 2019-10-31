//
//  AdVerification.swift
//  LoopMeServerCommuniator
//
//  Created by Bohdan on 8/16/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

import Foundation

public struct AdVerification {
    public static var empty = AdVerification(vendor: "", jsResource: "", verificationParameters: "")
    
    public var vendor: String
    public var jsResource: String
    public var verificationParameters: String
}
