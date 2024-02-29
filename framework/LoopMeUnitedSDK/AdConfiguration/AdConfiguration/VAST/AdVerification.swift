//
//  AdVerification.swift
//  LoopMeServerCommuniator
//
//  Created by Bohdan on 8/16/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

import Foundation

public struct AdVerification: Equatable {
    
    public static func == (lhs: AdVerification, rhs: AdVerification) -> Bool {
        return
            lhs.vendor == rhs.vendor &&
            lhs.jsResource == rhs.jsResource &&
            lhs.verificationParameters == rhs.verificationParameters
    }
    
    public static var empty = AdVerification(vendor: "", jsResource: "", verificationParameters: "")
    
    public var vendor: String
    public var jsResource: String
    public var verificationParameters: String
}
