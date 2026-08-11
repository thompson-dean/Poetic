//
//  PoemService.swift
//  Poetic
//
//  Created by Dean Thompson on 2026/08/11.
//

import Foundation

enum CatalogError: LocalizedError {
    case loadFailed

    var errorDescription: String? {
        "Something went wrong loading the poem library. Please restart the app."
    }
}

struct PoemSearchMatch: Hashable {
    let poem: Poem
    /// The first poem line containing the query, when the match came from the
    /// body rather than the title — shown as a snippet under the result.
    let matchedLine: String?
}

struct PoemSearchResults: Equatable {
    let authors: [String]
    let poems: [PoemSearchMatch]

    static let empty = PoemSearchResults(authors: [], poems: [])
}

protocol PoemServiceProtocol {
    /// For `.random`, `searchTerm` is the number of poems to return (e.g. "5"),
    /// mirroring the old PoetryDB endpoint shape.
    func fetchPoems(searchTerm: String, filter: SearchFilter) async throws -> [Poem]

    /// Unified search over authors, titles, and poem text.
    /// Case- and diacritic-insensitive; poems ranked title-match first.
    func search(matching query: String) async throws -> PoemSearchResults
}

/// Serves poems from the bundled `PoemCatalog.json` — no network involved.
/// The catalog is decoded once, off the main thread, on first use.
actor LocalPoemService: PoemServiceProtocol {
    private var loadTask: Task<[Poem], Error>?
    private let bundle: Bundle

    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }

    func fetchPoems(searchTerm: String, filter: SearchFilter) async throws -> [Poem] {
        let catalog = try await loadCatalog()
        switch filter {
        case .title:
            let needle = searchTerm.lowercased()
            return Array(catalog.filter { $0.title.lowercased().contains(needle) }.prefix(200))
        case .author:
            let needle = searchTerm.lowercased()
            return catalog.filter { $0.author.lowercased().contains(needle) }
        case .random:
            let count = Int(searchTerm) ?? 5
            return Array(catalog.shuffled().prefix(count))
        }
    }

    func search(matching query: String) async throws -> PoemSearchResults {
        let needle = Self.fold(query.trimmingCharacters(in: .whitespacesAndNewlines))
        guard !needle.isEmpty else { return .empty }
        let entries = try await loadIndex()

        var authors = Set<String>()
        var scored: [(score: Int, match: PoemSearchMatch)] = []

        for entry in entries {
            if entry.foldedAuthor.contains(needle) {
                authors.insert(entry.poem.author)
            }
            if let range = entry.foldedTitle.range(of: needle) {
                let score: Int
                if entry.foldedTitle == needle {
                    score = 100
                } else if range.lowerBound == entry.foldedTitle.startIndex {
                    score = 80
                } else {
                    score = 60
                }
                scored.append((score, PoemSearchMatch(poem: entry.poem, matchedLine: nil)))
            } else if let range = entry.foldedBody.range(of: needle) {
                let lineIndex = entry.foldedBody[..<range.lowerBound].lazy.filter { $0 == "\n" }.count
                let line = entry.poem.lines.indices.contains(lineIndex)
                    ? entry.poem.lines[lineIndex].trimmingCharacters(in: .whitespacesAndNewlines)
                    : nil
                scored.append((20, PoemSearchMatch(poem: entry.poem, matchedLine: line)))
            }
        }

        let rankedPoems = scored
            .sorted {
                if $0.score != $1.score { return $0.score > $1.score }
                return $0.match.poem.title < $1.match.poem.title
            }
            .prefix(50)
            .map(\.match)
        return PoemSearchResults(authors: Array(authors.sorted().prefix(10)), poems: Array(rankedPoems))
    }

    // MARK: - Index

    private struct IndexEntry {
        let poem: Poem
        let foldedTitle: String
        let foldedAuthor: String
        let foldedBody: String
    }

    private var index: [IndexEntry]?

    private static func fold(_ string: String) -> String {
        string.folding(
            options: [.caseInsensitive, .diacriticInsensitive],
            locale: Locale(identifier: "en_US_POSIX")
        )
    }

    private func loadIndex() async throws -> [IndexEntry] {
        if let index {
            return index
        }
        let catalog = try await loadCatalog()
        let built = catalog.map { poem in
            IndexEntry(
                poem: poem,
                foldedTitle: Self.fold(poem.title),
                foldedAuthor: Self.fold(poem.author),
                foldedBody: Self.fold(poem.lines.joined(separator: "\n"))
            )
        }
        index = built
        return built
    }

    private func loadCatalog() async throws -> [Poem] {
        if let task = loadTask {
            do {
                return try await task.value
            } catch {
                // Clear the memoized failure so a later call can retry.
                loadTask = nil
                throw error
            }
        }
        let bundle = self.bundle
        let task = Task<[Poem], Error>.detached(priority: .userInitiated) {
            guard let url = bundle.url(forResource: "PoemCatalog", withExtension: "json"),
                  let data = try? Data(contentsOf: url) else {
                throw CatalogError.loadFailed
            }
            do {
                return try JSONDecoder().decode([Poem].self, from: data)
            } catch {
                throw CatalogError.loadFailed
            }
        }
        loadTask = task
        do {
            return try await task.value
        } catch {
            loadTask = nil
            throw error
        }
    }
}
