//
//  OMSDKWrapper.swift
//  LoopMeUnitedSDK
//
//  Created by Valerii Roman on 09/04/2024.
//  Copyright © 2024 LoopMe. All rights reserved.
//

import Foundation
import OMSDK_Loopme
import ObjectiveC

struct MyError: Error {
    let message: String
}

class OMSDKWrapper {
    static var omidJS: String?
    static var partner: OMIDLoopmePartner?

    private var urlSession: URLSession?
    private var configuration: OMIDLoopmeAdSessionConfiguration?
    private var scripts: [Any] = []
    typealias CompletionHandlerBlock = (Data?, URLResponse?, Error?) -> Void

    static let partherName = "Loopme"
    static let cacheKey = "OMID_JS"
    static let omidJSURL = "https://i.loopme.me/html/ios/omsdk-v1.js"
    static var loopmeSDKVersionString: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }
    init() {
        scripts = []
    }

    static func initOMID(completionBlock: @escaping (Bool) -> Void) -> Bool {
        var error: Error?
        let sdkStarted = OMIDLoopmeSDK.shared.activate()

        guard sdkStarted, error == nil else {
            completionBlock(false)
            return false
        }

        loadJS(completionBlock: { completed in
            completionBlock(completed)
        })

        initPartner()

        return true
    }

    private static func loadJS(completionBlock: @escaping (Bool) -> Void) {
        let omidJSURL = URL(string: omidJSURL)!
        let request = URLRequest(url: omidJSURL)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completionBlock(false)
                return
            }

            self.omidJS = String(data: data, encoding: .utf8)
            completionBlock(true)
        }

        task.resume()
    }

    private static func initPartner() {
        partner = OMIDLoopmePartner(name: partherName, versionString: loopmeSDKVersionString)
    }

    func injectScriptContentIntoHTML(_ htmlString: String) throws -> String {
        guard let omidJS = OMSDKWrapper.omidJS else {
            throw NSError(domain: "OMSDKWrapper", code: -1, userInfo: [NSLocalizedDescriptionKey: "OMID JS not loaded"])
        }

        return try OMIDLoopmeScriptInjector.injectScriptContent(omidJS, intoHTML: htmlString)
    }

    func contextForHTML(_ webView: UIView) throws -> OMIDLoopmeAdSessionContext {
        guard let partner = OMSDKWrapper.partner else {
            throw NSError(domain: "OMSDKWrapper", code: -1, userInfo: [NSLocalizedDescriptionKey: "OMID partner not initialized"])
        }

        return try OMIDLoopmeAdSessionContext(partner: partner, webView: webView, contentUrl: nil, customReferenceIdentifier: "")
    }

    func contextForNativeVideo(_ resources: [AdVerificationWrapper], error: inout Error?) -> OMIDLoopmeAdSessionContext? {
        guard let partner = OMSDKWrapper.partner, let omidJS = OMSDKWrapper.omidJS else {
            error = NSError(domain: "OMSDKWrapper", code: -1, userInfo: [NSLocalizedDescriptionKey: "OMID partner or JS not initialized"])
            return nil
        }

        let omidResources = toOmidResources(resources)

        do {
            return try OMIDLoopmeAdSessionContext(partner: partner, script: omidJS, resources: omidResources, contentUrl: nil, customReferenceIdentifier: "")
        } catch let initializationError {
            error = initializationError
            return nil
        }
    }

    
    func toOmidResources(_ resources: [AdVerificationWrapper]) -> [OMIDLoopmeVerificationScriptResource] {
        var omidResources: [OMIDLoopmeVerificationScriptResource] = []
        for verification in resources {
            guard let resourceURL = URL(string: verification.jsResource) else {
                continue
            }
            let params = verification.verificationParameters
            let omidResource = OMIDLoopmeVerificationScriptResource(url: resourceURL, vendorKey: verification.vendor, parameters: params)
            if let omidResource = omidResource {
                omidResources.append(omidResource)
            }
        }
        return omidResources
    }

    func configurationFor(_ creativeType: OMIDCreativeType) throws -> OMIDLoopmeAdSessionConfiguration {
    try OMIDLoopmeAdSessionConfiguration(creativeType: creativeType, impressionType: .beginToRender, impressionOwner: .nativeOwner, mediaEventsOwner: .noneOwner, isolateVerificationScripts: false)
    }

    func sessionFor(_ configuration: OMIDLoopmeAdSessionConfiguration, context: OMIDLoopmeAdSessionContext) throws -> OMIDLoopmeAdSession {
            return  try OMIDLoopmeAdSession(configuration: configuration, adSessionContext: context)
    }

    func sessionForHTML(_ webView: UIView) throws -> OMIDLoopmeAdSession {
        let configuration = try configurationFor(.htmlDisplay)
        let context = try contextForHTML(webView)
        return try sessionFor(configuration, context: context)
    }

    func sessionForNativeVideo(_ resources: [AdVerificationWrapper]) throws -> OMIDLoopmeAdSession {
        var error: Error? = nil
        let configuration = try configurationFor(.video)
        if let context = contextForNativeVideo(resources, error: &error) {
            // If context is successfully retrieved, create and return the session
            return try sessionFor(configuration, context: context)
        } else {
            // If an error occurred, throw the error
            if let error = error {
                throw error
            } else {
                throw MyError(message: "Unknown error occurred")
            }
        }
    }
}
