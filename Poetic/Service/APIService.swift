//
//  DataManager.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import Foundation
import Combine
import Alamofire

protocol APIServiceProtocol {
    func fetchPoems(searchTerm: String, filter: SearchFilter) -> AnyPublisher<DataResponse<[Poem], NetworkError>, Never>
}

final class APIService {
    var count = 0
    
    static let shared: APIServiceProtocol = APIService()
    private init() { }
}

extension APIService: APIServiceProtocol {
    func fetchPoems(searchTerm: String, filter: SearchFilter) -> AnyPublisher<DataResponse<[Poem], NetworkError>, Never> {
        
        let urlString: String = APIConst.api + "\(filter)/\(searchTerm)"
        let url = URL(string: urlString)!
        print("DEBUG: \(urlString)")
        
        return AF.request(url, method: .get)
            .validate()
            .publishDecodable(type: [Poem].self)
            .map { response in
                response.mapError { error in
                    let backendError = response.data.flatMap { try? JSONDecoder().decode(BackendError.self, from: $0)}
                    return NetworkError(initialError: error, backendError: backendError)
                }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}



