//
//  MockAPIService.swift
//  PoeticTests
//
//  Created by Dean Thompson on 2023/07/15.
//

import Foundation
@testable import Poetic
import Combine
import Alamofire

final class MockAPIService: APIServiceProtocol, Mockable {
    
    var isFailedResponse: Bool = false
    
    func fetchPoems(searchTerm: String, filter: Poetic.SearchFilter) -> AnyPublisher<DataResponse<[Poem], NetworkError>, Never> {
        
        let poems: [Poem] = self.loadJSON(filename: "mockResponse", type: Poem.self)
        
        switch filter {
            
        case .author:
            let filtered = poems.filter { $0.author.contains(searchTerm) }
            if isFailedResponse {
                let publisher = failedResponse()
                return publisher
            } else {
                let response = DataResponse<[Poem], NetworkError>(request: nil, response: nil, data: nil, metrics: nil, serializationDuration: 0, result: .success(filtered))
                let publisher = Just(response)
                    .eraseToAnyPublisher()
                return publisher
            }
        case .title:
            let filtered = poems.filter { $0.title.contains(searchTerm) }
            if isFailedResponse {
                let publisher = failedResponse()
                return publisher
            } else {
                let response = DataResponse<[Poem], NetworkError>(request: nil, response: nil, data: nil, metrics: nil, serializationDuration: 0, result: .success(filtered))
                let publisher = Just(response)
                    .eraseToAnyPublisher()
                return publisher
            }
        case .random:
            if isFailedResponse {
                let publisher = failedResponse()
                return publisher
            } else {
                let response = DataResponse<[Poem], NetworkError>(request: nil, response: nil, data: nil, metrics: nil, serializationDuration: 0, result: .success(poems))
                let publisher = Just(response)
                    .eraseToAnyPublisher()
                return publisher
            }
        }
    }
    
    private func failedResponse() -> AnyPublisher<DataResponse<[Poem], NetworkError>, Never> {
        let error = URLError(.badURL)
        let response = DataResponse<[Poem], NetworkError>(request: nil, response: nil, data: nil, metrics: nil, serializationDuration: 0, result: .failure(NetworkError(initialError: .createURLRequestFailed(error: error), backendError: nil)))
        
        let publisher = Just(response)
            .eraseToAnyPublisher()
        
        return publisher
    }
}
