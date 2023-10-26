//
//  InfoPlistReader.swift
//  LoopMeSDK
//
//  Created by Bohdan on 11.10.2019.
//  Copyright © 2019 LoopMe. All rights reserved.
//

import Foundation

enum InfoPlistKey {
  static let iasID = "IAS_ID"
}

struct InfoPlisReader {

  private static var infoDict: [String: Any] {
    if let dict = Bundle.init(for: AdConfigurationWrapper.self).infoDictionary {
         return dict
     } else {
         fatalError("Info Plist file not found")
     }
  }

  static let iasID = infoDict[InfoPlistKey.iasID] as? String
}
