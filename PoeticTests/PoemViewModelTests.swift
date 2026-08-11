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
@MainActor
final class PoemViewModelTests: XCTestCase {
    var viewModel: PoemViewModel!
    var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        super.tearDown()
        viewModel = nil
    }

    func test_PoemViewModel_loadRandomPoems_returnsExpectedNumber() async {
        let expectation = XCTestExpectation(description: "Random Poems")

        // Given
        let number = "8"
        let mockService = MockPoemService()
        viewModel = PoemViewModel(service: mockService)

        // When
        viewModel.loadRandomPoems(number: number)

        // Then
        viewModel
            .$randomPoems
            .first(where: { !$0.isEmpty })
            .sink { value in
                XCTAssertEqual(value.count, 8, "The poems array should hold 8 Poem items.")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation], timeout: 2)
    }

    func test_PoemViewModel_loadRandomPoems_returnsNoPoemsWhenServiceFails() async {
        let expectation = XCTestExpectation(description: "Failed Service")

        // Given
        let number = "8"
        let mockService = MockPoemService()
        mockService.isFailedResponse = true
        viewModel = PoemViewModel(service: mockService)

        // When
        viewModel.loadRandomPoems(number: number)

        // Then
        viewModel
            .$state
            .first(where: { $0 == .failed })
            .sink { _ in
                XCTAssertTrue(
                    self.viewModel.randomPoems.isEmpty,
                    "The poems array should be empty because the service failed."
                )
                expectation.fulfill()
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation], timeout: 2)
    }

    func test_PoemViewModel_state_changesToLoadedAfterSuccessfulRequest() async {
        let expectation = XCTestExpectation(description: "State Success")

        // Given
        let number = "8"
        let mockService = MockPoemService()
        viewModel = PoemViewModel(service: mockService)

        // When
        XCTAssertEqual(viewModel.state, .idle, "The state should be .idle before fetching")
        viewModel.loadRandomPoems(number: number)

        // Then
        viewModel
            .$state
            .first(where: { $0 == .loaded })
            .sink { state in
                XCTAssertEqual(
                    state,
                    .loaded,
                    "The state should be .loaded when the fetch operation has completed."
                )
                expectation.fulfill()
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation], timeout: 2)
    }

    func test_PoemViewModel_state_changesToFailedAfterUnsuccessfulRequest() async {
        let expectation = XCTestExpectation(description: "State Failed")

        // Given
        let number = "8"
        let mockService = MockPoemService()
        mockService.isFailedResponse = true
        viewModel = PoemViewModel(service: mockService)

        // When
        XCTAssertEqual(viewModel.state, .idle, "The state should be .idle before fetching")
        viewModel.loadRandomPoems(number: number)

        // Then
        viewModel
            .$state
            .first(where: { $0 == .failed })
            .sink { state in
                XCTAssertEqual(
                    state,
                    .failed,
                    "The state should be .failed when the fetch operation has failed."
                )
                expectation.fulfill()
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation], timeout: 2)
    }

    func test_PoemViewModel_search_returnsExpectedPoems() async {
        let expectation = XCTestExpectation(description: "Search")

        // Given
        let searchTerm = "Defrauded"
        let mockService = MockPoemService()
        viewModel = PoemViewModel(service: mockService)

        // When
        viewModel.search(searchTerm: searchTerm)

        // Then
        viewModel
            .$searchPoems
            .first(where: { !$0.isEmpty })
            .sink { value in
                XCTAssertEqual(value.count, 1, "The searchPoems array should hold 1 match.")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation], timeout: 2)
    }

    func test_PoemViewModel_search_returnsExpectedPoemsAndAuthorsForWordInCommon() async {
        let expectation = XCTestExpectation(description: "Search Common Word")

        // Given
        let searchTerm = "d"
        let mockService = MockPoemService()
        viewModel = PoemViewModel(service: mockService)

        // When
        viewModel.search(searchTerm: searchTerm)

        // Then
        viewModel
            .$searchPoems
            .first(where: { !$0.isEmpty })
            .sink { value in
                XCTAssertEqual(value.count, 5, "The searchPoems array should hold 5 matches.")
                XCTAssertEqual(
                    self.viewModel.searchAuthors,
                    ["Emily Dickinson"],
                    "The searchAuthors array should hold the one author whose name contains the query."
                )
                expectation.fulfill()
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation], timeout: 2)
    }

    func test_PoemViewModel_search_returnsNoPoemsWhenServiceFails() async {
        let expectation = XCTestExpectation(description: "Search Failed")

        // Given
        let searchTerm = "d"
        let mockService = MockPoemService()
        mockService.isFailedResponse = true
        viewModel = PoemViewModel(service: mockService)

        // When
        viewModel.search(searchTerm: searchTerm)

        // Then
        viewModel
            .$searchState
            .first(where: { $0 == .failed })
            .sink { _ in
                XCTAssertTrue(
                    self.viewModel.searchPoems.isEmpty,
                    "The searchPoems array should be empty because the service failed."
                )
                expectation.fulfill()
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation], timeout: 2)
    }

    func test_PoemViewModel_search_emptyQuery_resetsToIdle() async {
        // Given
        let mockService = MockPoemService()
        viewModel = PoemViewModel(service: mockService)
        viewModel.search(searchTerm: "d")
        try? await Task.sleep(for: .milliseconds(300))

        // When
        viewModel.search(searchTerm: "   ")

        // Then
        XCTAssertEqual(viewModel.searchState, .idle, "A blank query should reset searchState to .idle.")
    }

    func test_PoemViewModel_searchState_ChangesToLoadedAfterSuccessfulSearch() async {
        let expectation = XCTestExpectation(description: "State Success on Search")

        // Given
        let searchTerm = "d"
        let mockService = MockPoemService()
        viewModel = PoemViewModel(service: mockService)

        // When
        XCTAssertEqual(viewModel.searchState, .idle, "The searchState should be .idle before fetching")
        viewModel.search(searchTerm: searchTerm)

        // Then
        viewModel
            .$searchState
            .first(where: { $0 == .loaded })
            .sink { state in
                XCTAssertEqual(
                    state,
                    .loaded,
                    "The searchState should be .loaded when the fetch operation has completed."
                )
                expectation.fulfill()
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation], timeout: 2)
    }

    func test_PoemViewModel_searchState_ChangesToFailedAfterUnsuccessfulSearch() async {
        let expectation = XCTestExpectation(description: "State Failure on Search")

        // Given
        let searchTerm = "d"
        let mockService = MockPoemService()
        mockService.isFailedResponse = true
        viewModel = PoemViewModel(service: mockService)

        // When
        XCTAssertEqual(viewModel.searchState, .idle, "The searchState should be .idle before fetching")
        viewModel.search(searchTerm: searchTerm)

        // Then
        viewModel
            .$searchState
            .first(where: { $0 == .failed })
            .sink { state in
                XCTAssertEqual(
                    state,
                    .failed,
                    "The searchState should be .failed when the fetch operation has failed."
                )
                expectation.fulfill()
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation], timeout: 2)
    }

    func test_PoemViewModel_loadAuthorPoem_returnsExpectedPoems() async {
        let expectation = XCTestExpectation(description: "Author Poem Loading")

        // Given
        let searchTerm = "Emily Dickins"
        let mockService = MockPoemService()
        viewModel = PoemViewModel(service: mockService)

        // When
        viewModel.loadAuthorPoem(searchTerm: searchTerm)

        // Then
        viewModel
            .$authorPoems
            .first(where: { !$0.isEmpty })
            .sink { value in
                XCTAssertEqual(value.count, 7, "The authorPoems array should hold 7 Poem items.")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation], timeout: 2)
    }

    func test_PoemViewModel_loadAuthorPoem_returnsExpectedPoemsForWordInCommon() async {
        let expectation = XCTestExpectation(description: "Author Poem Loading Common Word")

        // Given
        let searchTerm = "s"
        let mockService = MockPoemService()
        viewModel = PoemViewModel(service: mockService)

        // When
        viewModel.loadAuthorPoem(searchTerm: searchTerm)

        // Then
        viewModel
            .$authorPoems
            .first(where: { !$0.isEmpty })
            .sink { value in
                XCTAssertEqual(value.count, 8, "The authorPoems array should hold 8 Poem items.")
                expectation.fulfill()
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation], timeout: 2)
    }

    func test_PoemViewModel_loadAuthorPoem_returnsNoPoemsWhenServiceFails() async {
        let expectation = XCTestExpectation(description: "Author Poem Loading Failed")

        // Given
        let searchTerm = "Shakespeare"
        let mockService = MockPoemService()
        mockService.isFailedResponse = true
        viewModel = PoemViewModel(service: mockService)

        // When
        viewModel.loadAuthorPoem(searchTerm: searchTerm)

        // Then
        viewModel
            .$authorPoemState
            .first(where: { $0 == .failed })
            .sink { _ in
                XCTAssertTrue(
                    self.viewModel.authorPoems.isEmpty,
                    "The authorPoems array should be empty because the service failed."
                )
                expectation.fulfill()
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation], timeout: 2)
    }

    func test_PoemViewModel_authorPoemState_ChangesToLoadedAfterSuccessfulAuthorPoemLoad() async {
        let expectation = XCTestExpectation(description: "State Success on Author Poem Load")

        // Given
        let searchTerm = "emily"
        let mockService = MockPoemService()
        viewModel = PoemViewModel(service: mockService)

        // When
        XCTAssertEqual(viewModel.authorPoemState, .idle, "The authorPoemState should be .idle before loading")
        viewModel.loadAuthorPoem(searchTerm: searchTerm)

        // Then
        viewModel
            .$authorPoemState
            .first(where: { $0 == .loaded })
            .sink { state in
                XCTAssertEqual(
                    state,
                    .loaded,
                    "The authorPoemState should be .loaded when the load operation has completed."
                )
                expectation.fulfill()
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation], timeout: 2)
    }

    func test_PoemViewModel_authorPoemState_ChangesToFailedAfterUnsuccessfulAuthorPoemLoad() async {
        let expectation = XCTestExpectation(description: "State Failure on Author Poem Load")

        // Given
        let searchTerm = "r"
        let mockService = MockPoemService()
        mockService.isFailedResponse = true
        viewModel = PoemViewModel(service: mockService)

        // When
        XCTAssertEqual(viewModel.authorPoemState, .idle, "The authorPoemState should be .idle before loading")
        viewModel.loadAuthorPoem(searchTerm: searchTerm)

        // Then
        viewModel
            .$authorPoemState
            .first(where: { $0 == .failed })
            .sink { state in
                XCTAssertEqual(
                    state,
                    .failed,
                    "The authorPoemState should be .failed when the load operation has failed."
                )
                expectation.fulfill()
            }
            .store(in: &cancellables)

        await fulfillment(of: [expectation], timeout: 2)
    }

    func test_PoemViewModel_authorTitleCache_HoldsFetchedAuthorsAfterSuccessfulLoad() async {
        // Given
        let searchTerm = "Emily"
        let mockService = MockPoemService()
        viewModel = PoemViewModel(service: mockService)

        // When
        viewModel.loadAuthorPoem(searchTerm: searchTerm)

        // Then
        try? await Task.sleep(for: .seconds(1))
        XCTAssertFalse(
            viewModel.authorTitleCache.isEmpty,
            "The authorTitleCache should be populated after loading author poems."
        )
        XCTAssertEqual(
            viewModel.authorTitleCache[searchTerm]?.count,
            7,
            "The cache for the given search term should hold 7 Poem items."
        )
    }
}
// swiftlint:enable type_body_length file_length
