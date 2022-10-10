//
//  NetworkError.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/10/10.
//


import Foundation
import Alamofire

struct NetworkError: Error {
  let initialError: AFError
  let backendError: BackendError?
}

struct BackendError: Codable, Error {
    var status: String
    var message: String
}
