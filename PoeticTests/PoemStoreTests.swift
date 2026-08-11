//
//  PoemStoreTests.swift
//  PoeticTests
//
//  Created by Dean Thompson on 2026/08/11.
//

import XCTest
import CoreData
@testable import Poetic

@MainActor
final class PoemStoreTests: XCTestCase {
    private var store: PoemStore!

    override func setUp() {
        super.setUp()
        store = PoemStore(stack: PersistenceStack(inMemory: true))
    }

    override func tearDown() {
        store = nil
        super.tearDown()
    }

    // MARK: - Favorites

    func test_toggleFavorite_addsPoemToFavorites() {
        let poem = Poem.stub

        store.toggleFavorite(poem)

        XCTAssertEqual(store.favorites.count, 1)
        XCTAssertTrue(store.isFavorited(poem))
        XCTAssertEqual(store.favorites.first?.title, poem.title)
        XCTAssertEqual(store.favorites.first?.lines, poem.lines)
    }

    func test_toggleFavorite_twice_removesPoem() {
        let poem = Poem.stub

        store.toggleFavorite(poem)
        store.toggleFavorite(poem)

        XCTAssertTrue(store.favorites.isEmpty)
        XCTAssertFalse(store.isFavorited(poem))
    }

    func test_toggleFavorite_sameTitleAndAuthorTwice_yieldsOnePoemRow() {
        let poem = Poem.stub

        store.toggleFavorite(poem)
        store.markViewed(poem)

        XCTAssertEqual(store.favorites.count, 1)
        XCTAssertEqual(store.recents.count, 1)
        XCTAssertEqual(store.favorites.first, store.recents.first)
    }

    func test_deleteFavorites_removesPoem() {
        store.toggleFavorite(Poem.stub)

        store.deleteFavorites(at: IndexSet(integer: 0))

        XCTAssertTrue(store.favorites.isEmpty)
    }

    // MARK: - Quotes

    func test_addQuote_storesTrimmedTextWithPoemRelationship() {
        let poem = Poem.stub
        let rawLine = poem.lines[0]  // "From fairest creatures we desire increase,"

        store.addQuote("  \(rawLine)  ", to: poem)

        XCTAssertEqual(store.quotes.count, 1)
        XCTAssertEqual(store.quotes.first?.quote, rawLine)
        XCTAssertEqual(store.quotes.first?.poem.title, poem.title)
        XCTAssertTrue(store.hasQuote(rawLine, in: poem))
    }

    func test_addQuote_whitespaceVariantsOfSameLine_deduplicate() {
        let poem = Poem.stub

        store.addQuote("  \(poem.lines[0])", to: poem)
        store.addQuote("\(poem.lines[0])  ", to: poem)
        store.addQuote(poem.lines[0], to: poem)

        XCTAssertEqual(store.quotes.count, 1)
    }

    func test_addQuote_toFavoritedPoem_sharesTheSamePoemEntity() {
        let poem = Poem.stub

        store.toggleFavorite(poem)
        store.addQuote(poem.lines[0], to: poem)

        XCTAssertEqual(store.quotes.first?.poem, store.favorites.first)
    }

    func test_deleteQuotes_removesQuoteAndUnusedPoem() {
        let poem = Poem.stub
        store.addQuote(poem.lines[0], to: poem)

        store.deleteQuotes(at: IndexSet(integer: 0))

        XCTAssertTrue(store.quotes.isEmpty)
        XCTAssertTrue(store.favorites.isEmpty)
        XCTAssertTrue(store.recents.isEmpty)
    }

    // MARK: - Recents

    func test_markViewed_twice_keepsOneRowAndUpdatesRecency() {
        let poem = Poem.stub

        store.markViewed(poem)
        let firstViewedAt = store.recents.first?.lastViewedAt
        store.markViewed(poem)

        XCTAssertEqual(store.recents.count, 1)
        let secondViewedAt = store.recents.first?.lastViewedAt
        XCTAssertNotNil(secondViewedAt)
        XCTAssertGreaterThanOrEqual(secondViewedAt!, firstViewedAt!)
    }

    func test_pruneRecents_removesStaleButKeepsFavoritedAndQuoted() {
        let stale = Poem.stub
        let favorited = Poem(title: "Ode", author: "John Keats", lines: ["line one"], linecount: "1")

        store.markViewed(stale)
        store.markViewed(favorited)
        store.toggleFavorite(favorited)
        let old = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        store.recents.forEach { $0.lastViewedAt = old }

        store.pruneRecents(olderThan: 14)

        XCTAssertTrue(store.recents.isEmpty)
        XCTAssertEqual(store.favorites.count, 1)
        XCTAssertEqual(store.favorites.first?.title, "Ode")
    }
}
