//
//  AssetLinks.swift
//  LoopMeServerCommuniator
//
//  Created by Bohdan on 8/14/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

import Foundation

public struct AssetLinks {
    //Array because it needs to be sorted
    var video360URL: Array<String> = []
    var videoURL: Array<String> = []
    var vpaidURL: String = ""
    var adParameters: String = ""
    var endCard: Set<String> = []
}
