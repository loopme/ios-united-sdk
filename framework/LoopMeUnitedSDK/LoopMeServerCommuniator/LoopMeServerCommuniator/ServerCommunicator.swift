//
//  ServerCommunicator.swift
//  LoopMeServerCommuniator
//
//  Created by Bohdan on 8/9/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

import Foundation
//import AdConfiguration

@objc (LoopMeServerCommunicator)
open class ServerCommunicator: NSObject {
    public weak var delegate: LoopMeServerCommunicatorDelegate?
    public private(set) var isLoading: Bool = false
    @objc public var appKey: String?
    
    private var session: URLSession!
    private var dataTask: URLSessionDataTask!
    private var configuration: AdConfiguration?
    private var configurationWrapper: AdConfigurationWrapper?
    private var url: URL?
    private var data: Data!
    
    let adRequestTimeOutInterval: TimeInterval = 20.0
    let maxWrapperNodes = 5
    var wrapperRequestCounter: Int = 0
    
    @objc public init(delegate: LoopMeServerCommunicatorDelegate?) {
        super.init()
        self.delegate = delegate
        
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        configuration.timeoutIntervalForRequest = adRequestTimeOutInterval

        //TODO: get user agent
        configuration.httpAdditionalHeaders = ["User-Agent" :  UserAgent.defaultUserAgent, "x-openrtb-version" : "2.5"]
        self.session = URLSession(configuration: configuration, delegate: nil, delegateQueue: nil)
    }
    
    @objc public func load(url: URL, requestBody: Data?, method: String?) {
        cancel()
        
        self.url = url
        self.data = Data()
        
        var request = URLRequest(url: url, cachePolicy: .reloadRevalidatingCacheData, timeoutInterval: 60)
        request.httpMethod = method
        
        if let body = requestBody {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = body
        }
        
        dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            if let response = response as? HTTPURLResponse {
                self.isLoading = false
//                if response.statusCode == -999 {
//                    return
//                }
//                       
                if response.statusCode == 408 || response.statusCode == NSURLErrorTimedOut {
                   self.delegate?.serverCommunicator(self, didFailWith: ServerError.timeout)
                    return
                } else if response.statusCode == 204 {
                    self.delegate?.serverCommunicator(self, didFailWith: ServerError.noAds)
                    return
                } else if response.statusCode >= 500 {
                    self.delegate?.serverCommunicator(self, didFailWith: ServerError.serverError(response.statusCode))
                    return
                }
                       
                do {
                    guard let data = data else { return }
                    let configuration = try JSONDecoder().decode(AdConfiguration.self, from: data)
                    self.configuration = configuration
                    self.configurationWrapper = AdConfigurationWrapper(adConfiguration: configuration)
                    if let vastProperties = configuration.vastProperties,  vastProperties.isWrapper {
                        if self.wrapperRequestCounter >= self.maxWrapperNodes {
                            self.taskCompleted(success: false, error: ServerError.vastWrapperLimit)
                           
                            self.wrapperRequestCounter = 0;
                            return;
                        }
                       
                        self.wrapperRequestCounter += 1
                        guard let uri = configuration.vastProperties?.adTagURI, let url = URL(string: uri) else { return }
                        self.load(url: url, requestBody: nil, method: nil)
                    } else {
                        self.wrapperRequestCounter = 0;
                        self.taskCompleted(success: true, error: nil)
                    }
                } catch {
                   self.taskCompleted(success: false, error: ServerError.parsingError)
                   return
                }
            } else if let error = error as? URLError {
                if error.errorCode == -1001 {
                    self.taskCompleted(success: false, error: ServerError.timeout)
                } else {
                    self.taskCompleted(success: false, error: ServerError.some)
                }
                return
            }
        })
        dataTask.resume()
        
        if let properties = self.configuration?.vastProperties, properties.isWrapper {
            self.configuration = nil;
        }
        
        self.isLoading = true
    }
    
    @objc public func cancel() {
        self.isLoading = false
        self.dataTask?.cancel()
        self.dataTask = nil
    }
    
    
    func taskCompleted(success: Bool, error: Error?) {
        self.isLoading = false
        if let configuration = self.configurationWrapper {
            self.delegate?.serverCommunicator(self, didReceive: configuration)
        }
        if success {
            self.delegate?.serverCommunicatorDidReceiveAd(self)
        } else {
            self.delegate?.serverCommunicator(self, didFailWith: error)
        }
    }
}

@objc public protocol LoopMeServerCommunicatorDelegate: NSObjectProtocol {
    @objc func serverCommunicator(_ communicator: ServerCommunicator, didReceive adConfiguration: AdConfigurationWrapper)
    @objc func serverCommunicator(_ communicator: ServerCommunicator, didFailWith error: Error?)
    @objc func serverCommunicatorDidReceiveAd(_ communicator: ServerCommunicator)
}
