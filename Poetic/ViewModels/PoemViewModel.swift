//
//  PoemViewModel.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import SwiftUI
import Combine

class PoemViewModel: ObservableObject {
    enum State {
        case idle
        case loading
        case failed
        case loaded
    }

    enum SearchTitleState {
        case idle
        case loading
        case failed
        case loaded
    }

    enum AuthorPoemState {
        case idle
        case loading
        case failed
        case loaded
    }

    @AppStorage(Constants.darkModeEnable) var darkModeEnabled = false
    @AppStorage(Constants.systemThemeEnabled) var systemThemeEnabled = true
    @AppStorage(Constants.featuredAuthor1) var featuredAuthor1: String = ""
    @AppStorage(Constants.featuredAuthor2) var featuredAuthor2: String = ""
    @AppStorage(Constants.featuredAuthor3) var featuredAuthor3: String = ""

    @Published private(set) var poems = [Poem]()
    @Published private(set) var randomPoems = [Poem]()
    @Published private(set) var authorPoems = [Poem]()
    @Published var searchTerm: String = ""
    @Published var isTitle: Bool = true
    @Published var searchListLoadingError: String = ""

    private let apiService: APIServiceProtocol
    private var cancellables: Set<AnyCancellable> = []

    var authorTitleCache: [String: [Poem]] = [:]
    var poemTitleSearchCache: [String: [Poem]] = [:]

    @Published private(set) var state = State.idle
    @Published private(set) var searchState = SearchTitleState.idle
    @Published private(set) var authorPoemState = AuthorPoemState.idle

    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }

    func loadRandomPoems(number: String) {
        state = .loading
        apiService.fetchPoems(searchTerm: number, filter: .random)
            .sink { [weak self] (dataResponse) in
                if let error = dataResponse.error {
                    self?.createAlert(with: error)
                    self?.state = .failed
                } else if let poems = dataResponse.value {
                    self?.randomPoems = poems
                    self?.state = .loaded
                }
            }.store(in: &cancellables)
    }

    func fetchTitles(searchTerm: String) {
        if let cache = poemTitleSearchCache[searchTerm] {
            self.searchState = .loaded
            self.poems = cache
            return
        }
        let trimmedString = searchTerm.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedString != "" {
            searchState = .loading
            apiService.fetchPoems(searchTerm: trimmedString, filter: .title)
                .sink { [weak self] (dataResponse) in
                    if let error = dataResponse.error {
                        self?.createAlert(with: error)
                        self?.searchState = .failed
                    } else if let poems = dataResponse.value {
                        self?.poems = poems
                        self?.poemTitleSearchCache[searchTerm] = poems
                        self?.searchState = .loaded
                    }
                }.store(in: &cancellables)
        } else {
            searchState = .idle
        }
    }

    func listenToSearch() {
        $searchTerm
            .debounce(for: .milliseconds(350), scheduler: RunLoop.main, options: .none)
            .removeDuplicates()
            .sink { [weak self] delayQuery in
                guard let self = self else { return }
                if !delayQuery.isEmpty {
                    if self.isTitle {
                        self.fetchTitles(searchTerm: delayQuery)
                    }
                } else {
                    self.searchState = .idle
                }
            }
            .store(in: &self.cancellables)
    }

    func loadAuthorPoem(searchTerm: String) {
        if let cache = authorTitleCache[searchTerm] {
            self.authorPoemState = .loaded
            self.authorPoems = cache
            return
        }

        authorPoems = []
        authorPoemState = .loading

        apiService.fetchPoems(searchTerm: searchTerm, filter: .author)
            .sink { [weak self] (dataResponse) in
                if let error = dataResponse.error {
                    self?.createAlert(with: error)
                    self?.authorPoemState = .failed
                } else if let poems = dataResponse.value {
                    self?.authorPoems = poems
                    self?.authorTitleCache[searchTerm] = poems
                    self?.authorPoemState = .loaded
                }
            }.store(in: &cancellables)
    }

    func createAlert(with error: NetworkError) {
        searchListLoadingError = error.localizedDescription
    }

    func resetBadgeCount() {
        UNUserNotificationCenter.current().setBadgeCount(0) { error in
            if let error = error {
                print("Failed to set badge count: \(error.localizedDescription)")
            }
        }
    }
}
