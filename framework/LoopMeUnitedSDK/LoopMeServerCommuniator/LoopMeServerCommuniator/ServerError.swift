//
//  ServerError.swift
//  LoopMeServerCommuniator
//
//  Created by Bohdan on 8/19/19.
//  Copyright © 2019 LoopMe. All rights reserved.
//

import Foundation

enum ServerError: Error {
    case some
    case serverError(Int)
    case timeout
    case noAds
    case parsingError
    case vastWrapperLimit
    case noData
}

extension ServerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .timeout:
            return "Request time out"
        case .noAds:
            return "No ads found"
        case .parsingError:
            return "Response parsing error"
        case .vastWrapperLimit:
            return "Too much wrappers"
        case .serverError(let code):
            return "Server error code: \(code)"
        case .some:
            return "Unknown error"
        case .noData:
            return "Response empty data"
        }
    }
}
