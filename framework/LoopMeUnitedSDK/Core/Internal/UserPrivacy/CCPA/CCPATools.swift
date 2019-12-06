//
//  CCPATools.swift
//  LoopMeUnitedSDK
//
//  Created by Bohdan on 02.12.2019.
//  Copyright © 2019 LoopMe. All rights reserved.
//

import UIKit

@objc (LoopMeCCPATools)
public class CCPATools: NSObject {
    
    @objc
    public static var ccpaString: String {
        get {
            if let ccpa = UserDefaults.standard.string(forKey: "IABUSPrivacy_String") {
                return ccpa
            }
            return "1---"
        }
    }
}
