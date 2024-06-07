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
            return createResponse(filtered)
        case .title:
            let filtered = poems.filter { $0.title.contains(searchTerm) }
            return createResponse(filtered)
        case .random:
            return createResponse(poems)
        }
    }
    
    private func createResponse(_ poems: [Poem]) -> AnyPublisher<DataResponse<[Poem], NetworkError>, Never> {
        if isFailedResponse {
            return failedResponse()
        } else {
            let response = DataResponse<[Poem], NetworkError>(
                request: nil, response: nil, data: nil, metrics: nil, serializationDuration: 0,
                result: .success(poems)
            )
            return Just(response).eraseToAnyPublisher()
        }
    }
    
    private func failedResponse() -> AnyPublisher<DataResponse<[Poem], NetworkError>, Never> {
        let backendError = BackendError(status: "404", message: "Not Found")
        let networkError = NetworkError.backend(backendError)
        let response = DataResponse<[Poem], NetworkError>(
            request: nil, response: nil, data: nil, metrics: nil, serializationDuration: 0,
            result: .failure(networkError)
        )
        return Just(response).eraseToAnyPublisher()
    }
}
