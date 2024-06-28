//
//  ErrorInfoKey.swift
//  LoopMeUnitedSDK
//
//  Created by Valerii Roman on 27/06/2024.
//  Copyright © 2024 LoopMe. All rights reserved.
//

import Foundation


@objc public enum ErrorInfoKey: Int {
    case appKey
    case classKey
    case url
    case creativeType
     func toString() -> String {
        switch self {
        case .appKey: return "app_key"
        case .classKey: return "class"
        case .url: return "url"
        case .creativeType: return "creative_type"
        }
    }
    
}

@objc (LoopMeErrorInfoKey)
public class ErrorInfoKeyWrapper: NSObject {
    
    @objc public static func key(keyString: ErrorInfoKey) -> String {
         return keyString.toString()
     }

}
