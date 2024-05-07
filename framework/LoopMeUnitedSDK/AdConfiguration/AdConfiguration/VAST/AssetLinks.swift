//
//  AssetLinks.swift
//  LoopMeServerCommuniator
//
//  Created by Bohdan on 8/14/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

import Foundation

public struct AssetLinks: Equatable {
    
    public static func == (lhs: AssetLinks, rhs: AssetLinks) -> Bool {
        return
            lhs.vpaidURL == rhs.vpaidURL &&
            lhs.adParameters == rhs.adParameters &&
            lhs.endCard == rhs.endCard &&
            lhs.videoURL == rhs.videoURL
    }
    
    //Array because it needs to be sorted
    var videoURL: Array<String> = []
    var vpaidURL: String = ""
    var adParameters: String = ""
    var endCard: Set<String> = []
}
