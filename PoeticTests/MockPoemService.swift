//
//  MockPoemService.swift
//  PoeticTests
//
//  Created by Dean Thompson on 2023/07/15.
//

import Foundation
@testable import Poetic

final class MockPoemService: PoemServiceProtocol, Mockable {

    var isFailedResponse: Bool = false

    func fetchPoems(searchTerm: String, filter: SearchFilter) async throws -> [Poem] {
        if isFailedResponse {
            throw CatalogError.loadFailed
        }
        let poems: [Poem] = self.loadJSON(filename: "mockResponse", type: Poem.self)

        switch filter {
        case .author:
            return poems.filter { $0.author.contains(searchTerm) }
        case .title:
            return poems.filter { $0.title.contains(searchTerm) }
        case .random:
            return poems
        }
    }

    func allPoems() async throws -> [Poem] {
        if isFailedResponse {
            throw CatalogError.loadFailed
        }
        return self.loadJSON(filename: "mockResponse", type: Poem.self)
    }

    func poem(titled title: String, by author: String) async throws -> Poem? {
        if isFailedResponse {
            throw CatalogError.loadFailed
        }
        let poems: [Poem] = self.loadJSON(filename: "mockResponse", type: Poem.self)
        return poems.first { $0.title == title && $0.author == author }
    }

    func search(matching query: String) async throws -> PoemSearchResults {
        if isFailedResponse {
            throw CatalogError.loadFailed
        }
        let poems: [Poem] = self.loadJSON(filename: "mockResponse", type: Poem.self)
        let authors = Set(poems.map(\.author))
            .filter { $0.lowercased().contains(query.lowercased()) }
            .sorted()
        let matches = poems
            .filter { $0.title.contains(query) }
            .map { PoemSearchMatch(poem: $0, matchedLine: nil) }
        return PoemSearchResults(authors: authors, poems: matches)
    }
}
