//
//  CatalogTests.swift
//  PoeticTests
//
//  Created by Dean Thompson on 2026/08/11.
//

import XCTest
@testable import Poetic

/// Validates the generated PoemCatalog.json that ships in the app bundle.
final class CatalogTests: XCTestCase {

    private static let catalog: [Poem] = {
        guard let url = Bundle.main.url(forResource: "PoemCatalog", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let poems = try? JSONDecoder().decode([Poem].self, from: data) else {
            return []
        }
        return poems
    }()

    private static let authors: Authors = Bundle.main.decode("Authors.json")

    func test_catalog_decodesAndIsSubstantial() {
        XCTAssertGreaterThanOrEqual(Self.catalog.count, 3000)
    }

    func test_catalog_authorsMatchAuthorsJSON() {
        let catalogAuthors = Set(Self.catalog.map(\.author))
        let listedAuthors = Set(Self.authors.authors)
        XCTAssertEqual(
            catalogAuthors, listedAuthors,
            "Authors.json and the catalog must contain exactly the same authors."
        )
    }

    func test_catalog_poemsAreWellFormed() {
        for poem in Self.catalog {
            XCTAssertFalse(poem.title.isEmpty)
            XCTAssertFalse(poem.lines.isEmpty, "\(poem.title) has no lines")
            XCTAssertEqual(
                Int(poem.linecount), poem.lines.count,
                "\(poem.author) — \(poem.title): linecount mismatch"
            )
        }
    }

    func test_catalog_hasNoDuplicatePoems() {
        var seen = Set<String>()
        var duplicates = [String]()
        for poem in Self.catalog {
            let key = "\(poem.title.lowercased())|\(poem.author)"
            if !seen.insert(key).inserted {
                duplicates.append(key)
            }
        }
        XCTAssertTrue(duplicates.isEmpty, "duplicate poems: \(duplicates.prefix(5))")
    }

    func test_catalog_everyAuthorHasABioLink() {
        let missing = Set(Self.catalog.map(\.author))
            .filter { Links.authorLinksDictionary[$0] == nil }
            .sorted()
        XCTAssertTrue(missing.isEmpty, "authors missing from Links.swift: \(missing)")
    }

    func test_catalog_coldDecodeIsFast() throws {
        let url = try XCTUnwrap(Bundle.main.url(forResource: "PoemCatalog", withExtension: "json"))
        let data = try Data(contentsOf: url)
        measure {
            _ = try? JSONDecoder().decode([Poem].self, from: data)
        }
    }

    // MARK: - LocalPoemService behavior

    func test_localPoemService_titleSearchFindsSubstrings() async throws {
        let service = LocalPoemService()
        let results = try await service.fetchPoems(searchTerm: "ozymandias", filter: .title)
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.allSatisfy { $0.title.lowercased().contains("ozymandias") })
    }

    func test_localPoemService_randomReturnsRequestedCount() async throws {
        let service = LocalPoemService()
        let results = try await service.fetchPoems(searchTerm: "5", filter: .random)
        XCTAssertEqual(results.count, 5)
    }

    func test_localPoemService_unknownAuthorReturnsEmptyNotError() async throws {
        let service = LocalPoemService()
        let results = try await service.fetchPoems(searchTerm: "Zz Nobody", filter: .author)
        XCTAssertTrue(results.isEmpty)
    }

    func test_localPoemService_authorSearchIsCaseInsensitive() async throws {
        let service = LocalPoemService()
        let results = try await service.fetchPoems(searchTerm: "emily dickinson", filter: .author)
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.allSatisfy { $0.author == "Emily Dickinson" })
    }

    // MARK: - Unified search

    func test_search_exactTitleMatchRanksFirst() async throws {
        let service = LocalPoemService()
        let results = try await service.search(matching: "ozymandias")
        XCTAssertEqual(results.poems.first?.poem.title, "Ozymandias")
    }

    func test_search_isDiacriticInsensitive() async throws {
        let service = LocalPoemService()
        let results = try await service.search(matching: "kerity")
        XCTAssertTrue(
            results.poems.contains { $0.poem.title == "The Road to Kérity" },
            "Folded search should find Charlotte Mew's The Road to Kérity."
        )
    }

    func test_search_findsPoemsByLineWithSnippet() async throws {
        let service = LocalPoemService()
        let results = try await service.search(matching: "tyger, tyger, burning bright")
        let match = try XCTUnwrap(results.poems.first { $0.poem.title.contains("Tyger") })
        let snippet = try XCTUnwrap(match.matchedLine)
        XCTAssertTrue(snippet.lowercased().contains("tyger, tyger, burning bright"))
    }

    func test_search_titleMatchesRankAboveLineMatches() async throws {
        let service = LocalPoemService()
        // "daffodils" appears in titles and inside other poems' bodies.
        let results = try await service.search(matching: "daffodils")
        let firstLineMatchIndex = results.poems.firstIndex { $0.matchedLine != nil }
        let lastTitleMatchIndex = results.poems.lastIndex { $0.matchedLine == nil }
        if let lineIndex = firstLineMatchIndex, let titleIndex = lastTitleMatchIndex {
            XCTAssertLessThan(titleIndex, lineIndex, "All title matches should precede line matches.")
        }
    }

    func test_search_findsAuthorsSection() async throws {
        let service = LocalPoemService()
        let results = try await service.search(matching: "yeats")
        XCTAssertTrue(results.authors.contains("William Butler Yeats"))
    }

    func test_poemTitledBy_findsExactAndFoldedMatches() async throws {
        let service = LocalPoemService()
        let exact = try await service.poem(titled: "Ozymandias", by: "Percy Bysshe Shelley")
        XCTAssertEqual(exact?.title, "Ozymandias")
        let folded = try await service.poem(titled: "the road to kerity", by: "charlotte mew")
        XCTAssertEqual(folded?.title, "The Road to Kérity")
        let unknown = try await service.poem(titled: "Nonexistent", by: "Nobody")
        XCTAssertNil(unknown)
    }

    func test_search_emptyQueryReturnsNothing() async throws {
        let service = LocalPoemService()
        let results = try await service.search(matching: "   ")
        XCTAssertTrue(results.poems.isEmpty)
        XCTAssertTrue(results.authors.isEmpty)
    }
}
