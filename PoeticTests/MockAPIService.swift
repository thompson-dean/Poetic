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

final class MockAPIService: APIServiceProtocol, Mockable {    func fetchPoems(searchTerm: String, filter: Poetic.SearchFilter) -> AnyPublisher<DataResponse<[Poem], NetworkError>, Never> {
        
        let poems: [Poem] = self.loadJSON(filename: "mockResponse", type: Poem.self)
        
        let response = DataResponse<[Poem], NetworkError>(request: nil, response: nil, data: nil, metrics: nil, serializationDuration: 0, result: .success(poems))
        
        let publisher = Just(response)
            .eraseToAnyPublisher()
        
        return publisher
    }
    
}
