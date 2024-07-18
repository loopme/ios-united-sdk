//
//  LoopMeAdConfiguration.swift
//  LoopMeServerCommuniator
//
//  Created by Bohdan on 8/12/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

import Foundation
import UIKit

public let LOOPME_USERDEFAULTS_KEY_AUTOLOADING = "loopmeautoloading"

public struct SKAdNetworkFidelity: Codable {
    let fidelity: Int
    let signature: String
    let nonce: String
    let timestamp: String
}

public struct SKAdNetworkInfo: Codable {
    let version: String
    let network: String
    let campaign: String
    let itunesitem: String
    let sourceapp: String
    let sourceidentifier: String
    let fidelities: [SKAdNetworkFidelity]

    enum CodingKeys: String, CodingKey {
        case version, network, campaign, itunesitem, sourceapp, fidelities, sourceidentifier
    }
}

enum AdOrientation: String, Codable {
    case undefined
    case portrait
    case landscape
}

enum CreativeType: String, Codable {
    case vpaid = "VPAID"
    case vast = "VAST"
    case loopme = "HTML"
    case mraid = "MRAID"
}

public struct AdConfiguration {
    enum CodingKeys: String, CodingKey {
        case seatbid
        case bid
        case ext
        case adm
        case id
        case w
        case h
        case cid
        case crid
    }
    
    enum ExtKeys: String, CodingKey {
        case orientation
        case debug
        case crtype
        case adm
        case preload25
        case autoloading
        
        case advertiser
        case campaign
        case lineitem
        case id
        case appname
        case developer
        case company
        case skadn
    }
    
    let skAdNetworkInfo: SKAdNetworkInfo?
    let id: String
    let requestId: String
    let debug: Bool
    let crid: String
    let cid: String
    let preload25: Bool
    let autoloading: Bool
    var adOrientation: AdOrientation
    let height: Int
    let width: Int
    let creativeType: CreativeType
    
    var creativeContent: String
    var expandProperties: MRAIDExpandProperties
    var isRewarded: Bool

    var appKey: String = ""
    
    public var vastProperties: VastProperties?
}

extension AdConfiguration: Decodable {
    public init(from decoder: Decoder) throws {
        expandProperties = .empty
        self.isRewarded = false
        let response = try decoder.container(keyedBy: CodingKeys.self)
        var seatbidContainer = try response.nestedUnkeyedContainer(forKey: .seatbid)
        self.requestId = try response.decode(String.self, forKey: .id)
        let bidContainer = try seatbidContainer.nestedContainer(keyedBy: CodingKeys.self)
        //get bid element
        var bidValue = try bidContainer.nestedUnkeyedContainer(forKey: .bid)
        let bid = try bidValue.nestedContainer(keyedBy: CodingKeys.self)
        
        let id = try bid.decode(String.self, forKey: .id)
        self.id = id
        self.width = (try? bid.decode(Int.self, forKey: .w)) ?? 0
        self.height = (try? bid.decode(Int.self, forKey: .h)) ?? 0
        if width != 0 && height != 0 {
            self.adOrientation = width > height ? .landscape : .portrait
        } else {
            switch UIDevice.current.orientation{
            case .portrait:
                self.adOrientation = .portrait
            case .landscapeLeft, .landscapeRight:
                self.adOrientation = .landscape
            default:
                self.adOrientation = .landscape
            }
        }

        self.creativeContent = try bid.decode(String.self, forKey: .adm)
        self.cid = (try? bid.decode(String.self, forKey: .cid)) ?? ""
        self.crid = (try? bid.decode(String.self, forKey: .crid)) ?? ""
        //parse ext section
        let ext = try? bid.nestedContainer(keyedBy: ExtKeys.self, forKey: .ext)
        if let ext = ext {
            if let skAdNetworkContainer = try? ext.nestedContainer(keyedBy: SKAdNetworkInfo.CodingKeys.self, forKey: .skadn){
                let version = (try? skAdNetworkContainer.decode(String.self, forKey: .version) ) ?? ""
                let network = (try? skAdNetworkContainer.decode(String.self, forKey: .network)) ?? ""
                let campaign = (try? skAdNetworkContainer.decode(String.self, forKey: .campaign)) ?? "1"
                let itunesitem = (try? skAdNetworkContainer.decode(String.self, forKey: .itunesitem)) ?? ""
                let sourceapp = (try? skAdNetworkContainer.decode(String.self, forKey: .sourceapp)) ?? ""
                let sourceidentifier = (try? skAdNetworkContainer.decode(String.self, forKey: .sourceidentifier)) ?? "1000"
                let fidelities = (try? skAdNetworkContainer.decode([SKAdNetworkFidelity].self, forKey: .fidelities)) ?? [SKAdNetworkFidelity(fidelity: 1, signature: "", nonce: "", timestamp: "")]
                let skAdNetworkInfo = SKAdNetworkInfo(version: version, network: network, campaign: campaign, itunesitem: itunesitem, sourceapp: sourceapp, sourceidentifier: sourceidentifier, fidelities: fidelities)
                // Do something with skAdNetworkInfo
                self.skAdNetworkInfo = skAdNetworkInfo
            } else {
                self.skAdNetworkInfo = nil
            }
            self.debug = (try? ext.decode(Int.self, forKey: .debug) == 1) ?? false
            if let preload25 = try? ext.decode(Int.self, forKey: .preload25) {
                self.preload25 = preload25 == 1
            } else {
                self.preload25 = false
            }
            
            if let creativeType = try? ext.decode(CreativeType.self, forKey: .crtype) {
                self.creativeType = creativeType
            } else {
                let searchString = "<VAST"
                let isVast = self.creativeContent.range(of: searchString, options: .caseInsensitive) != nil
                self.creativeType = isVast ? .vast : .mraid
            }
            
            if let autoloading = try? ext.decode(Int.self, forKey: .autoloading) {
                self.autoloading = autoloading == 1
            } else {
                self.autoloading = true
            }
            
            UserDefaults.standard.set(autoloading, forKey: LOOPME_USERDEFAULTS_KEY_AUTOLOADING)
        } else {
            self.skAdNetworkInfo = nil
            self.debug = false
            self.preload25 = false
            
            let searchString = "<VAST"
            let isVast = self.creativeContent.range(of: searchString, options: .caseInsensitive) != nil
            self.creativeType = isVast ? .vast : .mraid
            
            self.autoloading = false
            
            UserDefaults.standard.set(autoloading, forKey: LOOPME_USERDEFAULTS_KEY_AUTOLOADING)
        }
        if self.creativeType == .vast || self.creativeType == .vpaid {
            guard let data = creativeContent.data(using: .utf8) else { fatalError() }
            
            vastProperties = VastProperties(data: data)
        }
    }
}
