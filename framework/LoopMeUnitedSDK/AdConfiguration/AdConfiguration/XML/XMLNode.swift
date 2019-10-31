//
//  XMLNode.swift
//  LoopMeServerCommuniator
//
//  Created by Bohdan on 8/14/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

import Foundation

protocol Node {
    var name: String { get set }
    var props: Dictionary<String, String> { get set }
    var parent: Node? { get set }
    var content: String? { get set }
}

struct XMLNode: Node {
    var name: String
    var props: Dictionary<String, String>
    var parent: Node?
    var content: String?
}
