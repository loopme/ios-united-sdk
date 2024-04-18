//
//  SDKUtility.swift
//  LoopMeUnitedSDK
//
//  Created by Valerii Roman on 17/04/2024.
//  Copyright © 2024 LoopMe. All rights reserved.
//

import Foundation

@objc public class SDKUtility: NSObject {
    @objc public static func loopmeSDKVersionString() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }
}
