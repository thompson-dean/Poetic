//
//  PoemViewModel.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import SwiftUI
import Combine

@MainActor
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

    @Published private(set) var searchAuthors = [String]()
    @Published private(set) var searchPoems = [PoemSearchMatch]()
    @Published private(set) var randomPoems = [Poem]()
    @Published private(set) var authorPoems = [Poem]()
    @Published var searchTerm: String = ""
    @Published var searchListLoadingError: String = ""

    private let service: PoemServiceProtocol
    private var cancellables: Set<AnyCancellable> = []
    private var searchTask: Task<Void, Never>?

    var authorTitleCache: [String: [Poem]] = [:]

    @Published private(set) var state = State.idle
    @Published private(set) var searchState = SearchTitleState.idle
    @Published private(set) var authorPoemState = AuthorPoemState.idle

    init(service: PoemServiceProtocol) {
        self.service = service

        // Live unified search, subscribed once for the view model's lifetime.
        // The catalog is local and in-memory, so every keystroke can search —
        // no debounce needed.
        $searchTerm
            .removeDuplicates()
            .sink { [weak self] query in
                self?.search(searchTerm: query)
            }
            .store(in: &cancellables)
    }

    func loadRandomPoems(number: String) {
        state = .loading
        Task {
            do {
                randomPoems = try await service.fetchPoems(searchTerm: number, filter: .random)
                state = .loaded
            } catch {
                createAlert(with: error)
                state = .failed
            }
        }
    }

    func search(searchTerm: String) {
        let trimmed = searchTerm.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            searchState = .idle
            return
        }
        searchState = .loading
        // Latest query wins: several lookups can be in flight, and a stale
        // result must not overwrite a newer one.
        searchTask?.cancel()
        searchTask = Task {
            do {
                let results = try await service.search(matching: trimmed)
                guard !Task.isCancelled else { return }
                searchAuthors = results.authors
                searchPoems = results.poems
                searchState = .loaded
            } catch {
                guard !Task.isCancelled else { return }
                createAlert(with: error)
                searchState = .failed
            }
        }
    }

    func loadAuthorPoem(searchTerm: String) {
        if let cache = authorTitleCache[searchTerm] {
            self.authorPoemState = .loaded
            self.authorPoems = cache
            return
        }

        authorPoems = []
        authorPoemState = .loading

        Task {
            do {
                let result = try await service.fetchPoems(searchTerm: searchTerm, filter: .author)
                authorPoems = result
                authorTitleCache[searchTerm] = result
                authorPoemState = .loaded
            } catch {
                createAlert(with: error)
                authorPoemState = .failed
            }
        }
    }

    func createAlert(with error: Error) {
        searchListLoadingError = (error as? CatalogError)?.errorDescription
            ?? "Something went wrong. Please try again."
    }

    func resetBadgeCount() {
        UNUserNotificationCenter.current().setBadgeCount(0) { error in
            if let error = error {
                print("Failed to set badge count: \(error.localizedDescription)")
            }
        }
    }
}
