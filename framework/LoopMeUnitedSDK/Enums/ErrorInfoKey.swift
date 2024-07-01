//
//  ErrorInfoKey.swift
//  LoopMeUnitedSDK
//
//  Created by Valerii Roman on 01/07/2024.
//  Copyright © 2024 LoopMe. All rights reserved.
//

import Foundation

public enum ErrorInfoKey: Int {
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

