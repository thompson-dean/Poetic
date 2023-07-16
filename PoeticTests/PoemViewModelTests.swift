//
//  PoemViewModelTests.swift
//  PoeticTests
//
//  Created by Dean Thompson on 2023/07/15.
//

import XCTest
@testable import Poetic
import Combine

final class PoemViewModelTests: XCTestCase {
    
    var viewModel: PoemViewModel!
    var cancellables = Set<AnyCancellable>()
    
    override func setUp() {
        super.setUp()
        viewModel = PoemViewModel(apiService: MockAPIService())
    }
    
    override func tearDown() {
        super.tearDown()
        viewModel = nil
    }
    
    func testFetchPoemsSuccessfully() {
        let expectation = XCTestExpectation(description: "Random Poems")
        
        viewModel.loadRandomPoems(number: "8")
        
        viewModel
            .$randomPoems
            .sink { value in
                XCTAssertFalse(value.isEmpty, "The poems array should be populated with data from the mock API service.")
                XCTAssertEqual(value.count, 8, "The poems aray should hold 8 Poem items.")
                XCTAssertEqual(self.viewModel.state, .loaded, "The state should be .loaded when the fetch operation has completed.")
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
    }
}
