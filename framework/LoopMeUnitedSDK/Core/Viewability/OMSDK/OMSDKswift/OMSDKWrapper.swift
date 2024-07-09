//
//  OMSDKWrapper.swift
//  LoopMeUnitedSDK
//
//  Created by Valerii Roman on 09/04/2024.
//  Copyright © 2024 LoopMe. All rights reserved.
//

import Foundation
import OMSDK_Loopme

struct OMIDSessionCustomError: Error {
    let message: String
}

@objc public class AdSessionContextResult: NSObject {
    @objc public var context: OMIDLoopmeAdSessionContext?
    @objc public var error: Error?
    
    @objc public init(context: OMIDLoopmeAdSessionContext?, error: Error?) {
        self.context = context
        self.error = error
    }
}

@objc (LoopMeOMIDWrapper)
public class OMSDKWrapper: NSObject {
    static var omidJS: String?
    static var partner: OMIDLoopmePartner?
    @objc static public var isReady: Bool = false

    private var urlSession: URLSession?
    private var configuration: OMIDLoopmeAdSessionConfiguration?
    typealias CompletionHandlerBlock = (Data?, URLResponse?, Error?) -> Void
    static let partherName = "Loopme"
    static let cacheKey = "OMID_JS"
    static let omidJSURL = "https://i.loopme.me/html/ios/omsdk-v1.js"
    


    @objc public static func initOMID(completionBlock: @escaping (Bool) -> Void) -> Bool {
        let sdkStarted = OMIDLoopmeSDK.shared.activate()

        guard sdkStarted else {
            completionBlock(false)
            return false
        }

        loadJS(completionBlock: { completed in
            self.isReady = completed
            completionBlock(completed)
        })

        partner = OMIDLoopmePartner(name: partherName, versionString: SDKUtility.loopmeSDKVersionString())

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


    @objc public func injectScriptContentIntoHTML(_ htmlString: String) throws -> String {
        guard let omidJS = OMSDKWrapper.omidJS else {
            throw NSError(
                domain: "OMSDKWrapper",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Can't inject OMID JS, because it is not loaded yet"]
            )
        }

        return try OMIDLoopmeScriptInjector.injectScriptContent(omidJS, intoHTML: htmlString)
    }

    @objc public func contextForHTML(_ webView: WKWebView) throws -> OMIDLoopmeAdSessionContext {
        guard let partner = OMSDKWrapper.partner else {
            throw NSError(domain: "OMSDKWrapper", code: -1, userInfo: [NSLocalizedDescriptionKey: "OMID partner not initialized"])
        }

        return try OMIDLoopmeAdSessionContext(partner: partner, webView: webView, contentUrl: nil, customReferenceIdentifier: "")
    }

    @objc public func contextForNativeVideo(_ resources: [AdVerificationWrapper]) -> AdSessionContextResult {
        guard let partner = OMSDKWrapper.partner, let omidJS = OMSDKWrapper.omidJS else {
            let error = NSError(domain: "OMSDKWrapper", code: -1, userInfo: [NSLocalizedDescriptionKey: "OMID partner or JS not initialized"])
            return AdSessionContextResult(context: nil, error: error)
        }
        
        let omidResources = toOmidResources(resources)
        
        do {
            let context = try OMIDLoopmeAdSessionContext(partner: partner, script: omidJS, resources: omidResources, contentUrl: nil, customReferenceIdentifier: "")
            return AdSessionContextResult(context: context, error: nil)
        } catch let initializationError {
            return AdSessionContextResult(context: nil, error: initializationError)
        }
    }

    
    @objc public func toOmidResources(_ resources: [AdVerificationWrapper]) -> [OMIDLoopmeVerificationScriptResource] {
        return resources.compactMap { verification in
            guard let resourceURL = URL(string: verification.jsResource),
                  let omidResource = OMIDLoopmeVerificationScriptResource(
                    url: resourceURL,
                    vendorKey: verification.vendor,
                    parameters: verification.verificationParameters
                  )
            else {
                return nil
            }
            return omidResource
        }
    }

    @objc public  func configurationFor(_ creativeType: OMIDCreativeType) throws -> OMIDLoopmeAdSessionConfiguration {
    try OMIDLoopmeAdSessionConfiguration(creativeType: creativeType, impressionType: .beginToRender, impressionOwner: .nativeOwner, mediaEventsOwner: .noneOwner, isolateVerificationScripts: false)
    }

    @objc public func sessionFor(_ configuration: OMIDLoopmeAdSessionConfiguration, context: OMIDLoopmeAdSessionContext) throws -> OMIDLoopmeAdSession {
            return  try OMIDLoopmeAdSession(configuration: configuration, adSessionContext: context)
    }

    @objc public func sessionForHTML(_ webView: WKWebView) throws -> OMIDLoopmeAdSession {
        let configuration = try configurationFor(.htmlDisplay)
        let context = try contextForHTML(webView)
        return try sessionFor(configuration, context: context)
    }

    @objc public func sessionForNativeVideo(_ resources: [AdVerificationWrapper]) throws -> OMIDLoopmeAdSession {
        let configuration = try configurationFor(.video)
        let contextResult = contextForNativeVideo(resources)
        
        // Check if context retrieval was successful
        if let context = contextResult.context {
            // If context is successfully retrieved, create and return the session
            return try sessionFor(configuration, context: context)
        } else {
            // If an error occurred, throw the error
            if let error = contextResult.error {
                throw error
            } else {
                throw OMIDSessionCustomError(message: "Unknown error occurred")
            }
        }
    }}
