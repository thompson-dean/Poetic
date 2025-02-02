//
//  PoemViewModelTests.swift
//  PoeticTests
//
//  Created by Dean Thompson on 2023/07/15.
//

import XCTest
@testable import Poetic
import Combine

// swiftlint:disable type_body_length file_length
final class PoemViewModelTests: XCTestCase {
    var viewModel: PoemViewModel!
    var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        super.tearDown()
        viewModel = nil
    }

    func test_PoemViewModel_loadRandomPoems_returnsExpectedNumber() {
        let expectation = XCTestExpectation(description: "Random Poems")

        // Given
        let number = "8"
        let mockService = MockAPIService()
        viewModel = PoemViewModel(apiService: mockService)

        // When
        viewModel.loadRandomPoems(number: number)

        // Then
        viewModel
            .$randomPoems
            .sink { value in
                XCTAssertFalse(
                    value.isEmpty,
                    "The poems array should be populated with data from the mock API service."
                )
                XCTAssertEqual(value.count, 8, "The poems aray should hold 8 Poem items.")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func test_PoemViewModel_loadRandomPoems_returnsNoPoemsWhenServiceFails() {
         let expectation = XCTestExpectation(description: "Failed Service")

         // Given
         let number = "8"
         let mockService = MockAPIService()
         mockService.isFailedResponse = true
         viewModel = PoemViewModel(apiService: mockService)

         // When
         viewModel.loadRandomPoems(number: number)

         // Then
         viewModel
             .$randomPoems
             .sink { value in
                 XCTAssertTrue(value.isEmpty, "The poems array should be empty because the API service failed.")
                 XCTAssertEqual(value.count, 0, "The poems array should hold 0 Poem items.")
                 expectation.fulfill()
             }
             .store(in: &cancellables)

         wait(for: [expectation], timeout: 1)
     }

    func test_PoemViewModel_state_changesToLoadedAfterSuccessfulRequest() {
        let expectation = XCTestExpectation(description: "State Success")

        // Given
        let number = "8"
        let mockService = MockAPIService()
        viewModel = PoemViewModel(apiService: mockService)

        // When
        XCTAssertEqual(viewModel.state, .idle, "The state should be .idle before fetching")
        viewModel.loadRandomPoems(number: number)

        // Then
        viewModel
            .$randomPoems
            .sink { _ in
                XCTAssertEqual(
                    self.viewModel.state,
                    .loaded,
                    "The state should be .loaded when the fetch operation has completed."
                )
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func test_PoemViewModel_state_changesToFailedAfterUnsuccessfulRequest() {
        let expectation = XCTestExpectation(description: "State Failed")

        // Given
        let number = "8"
        let mockService = MockAPIService()
        mockService.isFailedResponse = true
        viewModel = PoemViewModel(apiService: mockService)

        // When
        XCTAssertEqual(viewModel.state, .idle, "The state should be .idle before fetching")
        viewModel.loadRandomPoems(number: number)

        // Then
        viewModel
            .$randomPoems
            .sink { _ in
                XCTAssertEqual(
                    self.viewModel.state,
                    .failed,
                    "The state should be .failed when the fetch operation has failed."
                )
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func test_PoemViewModel_fetchTitles_returnsExpectedPoems() {
        let expectation = XCTestExpectation(description: "Title Fetching")

        // Given
        let searchTerm = "Defrauded"
        let mockService = MockAPIService()
        viewModel = PoemViewModel(apiService: mockService)

        // When
        viewModel.fetchTitles(searchTerm: searchTerm)

        // Then
        viewModel
            .$poems
            .sink { value in
                XCTAssertFalse(
                    value.isEmpty,
                    "The poems array should be populated with data from the mock API service."
                )
                XCTAssertEqual(value.count, 1, "The poems array should hold 1 Poem items.")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func test_PoemViewModel_fetchTitles_returnsExpectedPoemsForWordInCommon() {
        let expectation = XCTestExpectation(description: "Title Fetching Common Word")

        // Given
        let searchTerm = "d"
        let mockService = MockAPIService()
        viewModel = PoemViewModel(apiService: mockService)

        // When
        viewModel.fetchTitles(searchTerm: searchTerm)

        // Then
        viewModel
            .$poems
            .sink { value in
                XCTAssertFalse(
                    value.isEmpty,
                    "The poems array should be populated with data from the mock API service."
                )
                XCTAssertEqual(value.count, 5, "The poems array should hold 1 Poem items.")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func test_PoemViewModel_fetchTitles_returnsNoPoemsWhenServiceFails() {
        let expectation = XCTestExpectation(description: "Title Fetching Common Word")

        // Given
        let searchTerm = "d"
        let mockService = MockAPIService()
        mockService.isFailedResponse = true
        viewModel = PoemViewModel(apiService: mockService)

        // When
        viewModel.fetchTitles(searchTerm: searchTerm)

        // Then
        viewModel
            .$poems
            .sink { value in
                XCTAssertTrue(
                    value.isEmpty,
                    "The poems array should be empty because the API service failed."
                )
                XCTAssertEqual(value.count, 0, "The poems array should hold 0 Poem items.")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func test_PoemViewModel_searchState_ChangesToLoadedAfterSuccessfulTitleFetch() {
        let expectation = XCTestExpectation(description: "State Success on Title Fetch")

        // Given
        let searchTerm = "d"
        let mockService = MockAPIService()
        viewModel = PoemViewModel(apiService: mockService)

        // When
        XCTAssertEqual(viewModel.searchState, .idle, "The searchState should be .idle before fetching")
        viewModel.fetchTitles(searchTerm: searchTerm)

        // Then
        viewModel
            .$searchState
            .sink { _ in
                XCTAssertEqual(
                    self.viewModel.searchState,
                    .loaded,
                    "The searchState should be .loaded when the fetch operation has completed."
                )
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func test_PoemViewModel_searchState_ChangesToFailedAfterUnsuccessfulTitleFetch() {
        let expectation = XCTestExpectation(description: "State Success on Title Fetch")

        // Given
        let searchTerm = "d"
        let mockService = MockAPIService()
        mockService.isFailedResponse = true
        viewModel = PoemViewModel(apiService: mockService)

        // When
        XCTAssertEqual(viewModel.searchState, .idle, "The searchState should be .idle before fetching")
        viewModel.fetchTitles(searchTerm: searchTerm)

        // Then
        viewModel
            .$searchState
            .sink { _ in
                XCTAssertEqual(
                    self.viewModel.searchState,
                    .failed,
                    "The searchState should be .failed when the fetch operation has failed."
                )
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func test_PoemViewModel_poemTitleSearchCache_HoldsFetchedTitlesAfterSuccessfulFetch() {
        let expectation = XCTestExpectation(description: "Cache Populated")

        // Given
        let searchTerm = "d"
        let mockService = MockAPIService()
        viewModel = PoemViewModel(apiService: mockService)

        // When
        viewModel.fetchTitles(searchTerm: searchTerm)

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertFalse(
                self.viewModel.poemTitleSearchCache.isEmpty,
                "The poemTitleSearchCache should be populated after fetching titles."
            )
            XCTAssertEqual(
                self.viewModel.poemTitleSearchCache[searchTerm]?.count,
                5,
                "The cache for the given search term should hold 5 Poem items."
            )
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2)
    }

    func test_PoemViewModel_loadAuthorPoem_returnsExpectedPoems() {
        let expectation = XCTestExpectation(description: "Author Poem Loading")

        // Given
        let searchTerm = "Emily Dickins"
        let mockService = MockAPIService()
        viewModel = PoemViewModel(apiService: mockService)

        // When
        viewModel.loadAuthorPoem(searchTerm: searchTerm)

        // Then
        viewModel
            .$authorPoems
            .sink { value in
                XCTAssertFalse(
                    value.isEmpty,
                    "The authorPoems array should be populated with data from the mock API service."
                )
                XCTAssertEqual(value.count, 7, "The authorPoems array should hold 7 Poem items.")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func test_PoemViewModel_loadAuthorPoem_returnsExpectedPoemsForWordInCommon() {
        let expectation = XCTestExpectation(description: "Author Poem Loading Common Word")

        // Given
        let searchTerm = "s"
        let mockService = MockAPIService()
        viewModel = PoemViewModel(apiService: mockService)

        // When
        viewModel.loadAuthorPoem(searchTerm: searchTerm)

        // Then
        viewModel
            .$authorPoems
            .sink { value in
                XCTAssertFalse(
                    value.isEmpty,
                    "The authorPoems array should be populated with data from the mock API service."
                )
                XCTAssertEqual(value.count, 8, "The authorPoems array should hold 8 Poem items.")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func test_PoemViewModel_loadAuthorPoem_returnsNoPoemsWhenServiceFails() {
        let expectation = XCTestExpectation(description: "Author Poem Loading Failed")

        // Given
        let searchTerm = "Shakespeare"
        let mockService = MockAPIService()
        mockService.isFailedResponse = true
        viewModel = PoemViewModel(apiService: mockService)

        // When
        viewModel.loadAuthorPoem(searchTerm: searchTerm)

        // Then
        viewModel
            .$authorPoems
            .sink { value in
                XCTAssertTrue(value.isEmpty, "The authorPoems array should be empty because the API service failed.")
                XCTAssertEqual(value.count, 0, "The authorPoems array should hold 0 Poem items.")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func test_PoemViewModel_authorPoemState_ChangesToLoadedAfterSuccessfulAuthorPoemLoad() {
        let expectation = XCTestExpectation(description: "State Success on Author Poem Load")

        // Given
        let searchTerm = "emily"
        let mockService = MockAPIService()
        viewModel = PoemViewModel(apiService: mockService)

        // When
        XCTAssertEqual(viewModel.authorPoemState, .idle, "The authorPoemState should be .idle before loading")
        viewModel.loadAuthorPoem(searchTerm: searchTerm)

        // Then
        viewModel
            .$authorPoemState
            .sink { _ in
                XCTAssertEqual(
                    self.viewModel.authorPoemState,
                    .loaded,
                    "The authorPoemState should be .loaded when the load operation has completed."
                )
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func test_PoemViewModel_authorPoemState_ChangesToFailedAfterUnsuccessfulAuthorPoemLoad() {
        let expectation = XCTestExpectation(description: "State Failure on Author Poem Load")

        // Given
        let searchTerm = "r"
        let mockService = MockAPIService()
        mockService.isFailedResponse = true
        viewModel = PoemViewModel(apiService: mockService)

        // When
        XCTAssertEqual(viewModel.authorPoemState, .idle, "The authorPoemState should be .idle before loading")
        viewModel.loadAuthorPoem(searchTerm: searchTerm)

        // Then
        viewModel
            .$authorPoemState
            .sink { _ in
                XCTAssertEqual(
                    self.viewModel.authorPoemState,
                    .failed,
                    "The authorPoemState should be .failed when the load operation has failed."
                )
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func test_PoemViewModel_authorTitleCache_HoldsFetchedAuthorsAfterSuccessfulLoad() {
        let expectation = XCTestExpectation(description: "Cache Populated")

        // Given
        let searchTerm = "Emily"
        let mockService = MockAPIService()
        viewModel = PoemViewModel(apiService: mockService)

        // When
        viewModel.loadAuthorPoem(searchTerm: searchTerm)

        // Then
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertFalse(
                self.viewModel.authorTitleCache.isEmpty,
                "The authorTitleCache should be populated after loading author poems."
            )
            XCTAssertEqual(
                self.viewModel.authorTitleCache[searchTerm]?.count,
                7,
                "The cache for the given search term should hold 7 Poem items."
            )
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2)
    }
}
// swiftlint:enable type_body_length file_length
