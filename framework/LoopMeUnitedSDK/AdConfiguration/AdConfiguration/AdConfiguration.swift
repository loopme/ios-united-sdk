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

enum TrackerName: String {
    case ias
    case moat
    
    init(intValue: Int) {
        switch intValue {
        case 0: self = .ias
        case 1: self = .moat
        default: self = .ias
        }
    }
}

public struct AdConfiguration {
    enum CodingKeys: String, CodingKey {
        case seatbid
        case bid
        case ext
        case adm
        case id
    }
    
    enum ExtKeys: String, CodingKey {
        case v360
        case orientation
        case debug
        case crtype
        case adm
        case preload25
        case autoloading
        case measure_partners
        
        case advertiser
        case campaign
        case lineitem
        case id
        case appname
        case developer
        case company
        case skadn
        case version

    }
    
    let skAdNetworkInfo: SKAdNetworkInfo?
    let id: String
    let v360: Bool
    let debug: Bool
    let preload25: Bool
    let autoloading: Bool
    let adOrientation: AdOrientation
    let creativeType: CreativeType
    let measurePartners: [String]
    
    var creativeContent: String
    var adIDsForMoat: Dictionary<String, Any>
    var adIDsForIAS: Dictionary<String, Any>
    var expandProperties: MRAIDExpandProperties
    var appKey: String = "" {
        didSet {
//            var iasIds = adIDsForIAS
            var placementId: String = adIDsForIAS["placementId"] as? String ?? ""
            placementId += "_\(appKey)"
            adIDsForIAS["placementId"] = placementId
        }
    }
    
    public var vastProperties: VastProperties?
    
    func useTracking(trackerName: TrackerName) -> Bool {
        return self.measurePartners.contains(trackerName.rawValue)
    }
}

extension AdConfiguration: Decodable {
    public init(from decoder: Decoder) throws {
        print("Decoding AdConfiguration")

        expandProperties = .empty
        
        let response = try decoder.container(keyedBy: CodingKeys.self)
        var seatbidContainer = try response.nestedUnkeyedContainer(forKey: .seatbid)
        let bidContainer = try seatbidContainer.nestedContainer(keyedBy: CodingKeys.self)
        //get bid element
        var bidValue = try bidContainer.nestedUnkeyedContainer(forKey: .bid)
        let bid = try bidValue.nestedContainer(keyedBy: CodingKeys.self)
        
        let id = try bid.decode(String.self, forKey: .id)
        self.id = id
        self.creativeContent = try bid.decode(String.self, forKey: .adm)
        
//         parse ext section
        let ext = try? bid.nestedContainer(keyedBy: ExtKeys.self, forKey: .ext)
        if let ext = ext {
            
            if let skAdNetworkContainer = try? ext.nestedContainer(keyedBy: SKAdNetworkInfo.CodingKeys.self, forKey: .skadn){
                let version = (try? skAdNetworkContainer.decode(String.self, forKey: .version) ) ?? ""
                let network = (try? skAdNetworkContainer.decode(String.self, forKey: .network)) ?? ""
                let campaign = (try? skAdNetworkContainer.decode(String.self, forKey: .campaign)) ?? "1"
                let itunesitem = (try? skAdNetworkContainer.decode(String.self, forKey: .itunesitem)) ?? ""
                let sourceapp = (try? skAdNetworkContainer.decode(String.self, forKey: .sourceapp)) ?? "1000"
                let sourceidentifier = (try? skAdNetworkContainer.decode(String.self, forKey: .sourceidentifier)) ?? ""
                let fidelities = (try? skAdNetworkContainer.decode([SKAdNetworkFidelity].self, forKey: .fidelities)) ?? [SKAdNetworkFidelity(fidelity: 1, signature: "", nonce: "", timestamp: "")]
                let skAdNetworkInfo = SKAdNetworkInfo(version: version, network: network, campaign: campaign, itunesitem: itunesitem, sourceapp: sourceapp, sourceidentifier: sourceidentifier, fidelities: fidelities)
                // Do something with skAdNetworkInfo
                self.skAdNetworkInfo = skAdNetworkInfo

            } else {
                self.skAdNetworkInfo = nil
            }
            self.v360 = (try? ext.decode(Int.self, forKey: .v360) == 1) ?? false
            self.debug = (try? ext.decode(Int.self, forKey: .debug) == 1) ?? false
            if let preload25 = try? ext.decode(Int.self, forKey: .preload25) {
                self.preload25 = preload25 == 1
            } else {
                self.preload25 = false
            }
            self.adOrientation = (try? ext.decode(AdOrientation.self, forKey: .orientation)) ?? .landscape
            
            if let creativeType = try? ext.decode(CreativeType.self, forKey: .crtype) {
                self.creativeType = creativeType
            } else {
                let searchString = "<VAST"
                let isVast = self.creativeContent.range(of: searchString, options: .caseInsensitive) != nil
                self.creativeType = isVast ? .vast : .mraid
            }
            
            self.adIDsForIAS =  (try? AdConfiguration.initAdIDs(for: .ias, decoder: ext, id: id)) ?? ["":""]
            self.adIDsForMoat = (try? AdConfiguration.initAdIDs(for: .moat, decoder: ext)) ?? ["":""]
            
            if let autoloading = try? ext.decode(Int.self, forKey: .autoloading) {
                self.autoloading = autoloading == 1
            } else {
                self.autoloading = true
            }
            
            UserDefaults.standard.set(autoloading, forKey: LOOPME_USERDEFAULTS_KEY_AUTOLOADING)
            
            self.measurePartners = (try? ext.decode([String].self, forKey: .measure_partners)) ?? [""]
            
        } else {
            self.skAdNetworkInfo = nil
            self.v360 = false
            self.debug = false
            self.preload25 = false
            
            switch UIDevice.current.orientation{
            case .portrait:
                self.adOrientation = .portrait
            case .landscapeLeft, .landscapeRight:
                self.adOrientation = .landscape
            default:
                self.adOrientation = .landscape
            }
            
            let searchString = "<VAST"
            let isVast = self.creativeContent.range(of: searchString, options: .caseInsensitive) != nil
            self.creativeType = isVast ? .vast : .mraid
            
            self.adIDsForIAS =  Dictionary()
            self.adIDsForMoat = Dictionary()
            
            self.autoloading = false
            
            UserDefaults.standard.set(autoloading, forKey: LOOPME_USERDEFAULTS_KEY_AUTOLOADING)
            
            self.measurePartners = []
        }
        if self.creativeType == .vast || self.creativeType == .vpaid {
            guard let data = creativeContent.data(using: .utf8) else { fatalError() }
            
            vastProperties = VastProperties(data: data)
        }
    }
    
    static func initAdIDs(for tracker: TrackerName, decoder: KeyedDecodingContainer<ExtKeys>, id: String = "") throws -> Dictionary<String, Any> {
        
        guard let advertiser = try? decoder.decode(String.self, forKey: .advertiser),
        let campaign = try? decoder.decode(String.self, forKey: .campaign),
            let level3 = try? decoder.decode(String.self, forKey: .lineitem),
            let level5 = try? decoder.decode(String.self, forKey: .appname) else { return [:] }
        
        let level4 = id
        
        if tracker == .moat {
            let _adIdsForMOAT = ["level1" : advertiser, "level2" : campaign, "level3" : level3, "level4" : level4, "level5" : level5, "slicer1" : "", "slicer2" : ""]
            return _adIdsForMOAT
        }
        
        let placemantid = "\(level5)"
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "unknown"
        
        let anId = InfoPlisReader.iasID
        
        guard let company = try? decoder.decode(String.self, forKey: .company),
            let developer = try? decoder.decode(String.self, forKey: .developer) else { return [:] }
            
        let pubId = "\(company)_\(developer)"
        
        let _adIdsForIAS = [ "anId" : anId, "advId" : advertiser, "campId" : campaign, "pubId" : pubId, "chanId" : bundleIdentifier, "placementId" : placemantid, "bundleId" : bundleIdentifier];
        
        return _adIdsForIAS
    }
}

extension AdConfiguration {
    
//    private func returnv360<T>(object: KeyedDecodingContainer<ExtKeys>?, key: ExtKeys, defualtValue: T, type: Decodable) -> T {
//        if let v360 = try object?.decode(type, forKey: key) {
//            return v360 as! T
//        }
//      return defualtValue
//        
//    }
}
