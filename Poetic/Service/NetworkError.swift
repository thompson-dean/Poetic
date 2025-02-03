//
//  NetworkError.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/10/10.
//

import Foundation

enum NetworkError: Error {
    case noNetwork
    case noResults
    case backend(BackendError)
    case unknown(Error)

    var localizedDescription: String {
        switch self {
        case .noNetwork:
            return "No network connection. Please check your internet connection and try again."
        case .noResults:
            return "No results found. Please try a different search term."
        case .backend(let error):
            return error.message
        case .unknown:
            return "No results found. Please try a different search term."
        }
    }
}

struct BackendError: Codable, Error {
    var message: String
}
