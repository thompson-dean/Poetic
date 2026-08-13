//
//  WidgetFoundationTests.swift
//  PoeticTests
//
//  Created by Dean Thompson on 2026/08/11.
//

import XCTest
@testable import Poetic

final class WidgetDataStoreTests: XCTestCase {
    private var directory: URL!
    private var store: WidgetDataStore!

    override func setUpWithError() throws {
        try super.setUpWithError()
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        store = WidgetDataStore(containerURL: directory)
    }

    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: directory)
        directory = nil
        store = nil
        try super.tearDownWithError()
    }

    private let poem = WidgetPoem(
        title: "Ozymandias", author: "Percy Bysshe Shelley",
        excerptLines: ["I met a traveller from an antique land"], totalLineCount: 14
    )

    func test_dailyPayload_roundTrips() {
        let payload = DailyPayload(
            version: 1, appVersion: "2.4.0",
            days: [DailyPayload.DayEntry(dateKey: "2026-08-11", poem: poem)]
        )
        store.writeDaily(payload)
        XCTAssertEqual(store.readDaily(), payload)
    }

    func test_favoritesPayload_roundTripsAndCapsAtThirty() {
        let many = (0..<40).map {
            WidgetPoem(title: "Poem \($0)", author: "A", excerptLines: ["line one"], totalLineCount: 4)
        }
        store.writeFavorites(FavoritesPayload(version: 1, poems: many))
        XCTAssertEqual(store.readFavorites()?.poems.count, FavoritesPayload.maximumPoems)
    }

    func test_overwrite_replacesPayload() {
        store.writeFavorites(FavoritesPayload(version: 1, poems: [poem]))
        store.writeFavorites(FavoritesPayload(version: 1, poems: []))
        XCTAssertEqual(store.readFavorites()?.poems.count, 0)
    }

    func test_nilContainer_noOpsAndReadsNil() {
        let unavailable = WidgetDataStore(containerURL: nil)
        unavailable.writeDaily(DailyPayload(version: 1, appVersion: "2.4.0", days: []))
        XCTAssertNil(unavailable.readDaily())
        XCTAssertNil(unavailable.readFavorites())
    }
}

final class DailyPoemPickerTests: XCTestCase {
    private func poem(_ title: String, _ author: String, lineCount: Int) -> Poem {
        Poem(
            title: title, author: author,
            lines: (0..<lineCount).map { "line number \($0)" },
            linecount: String(lineCount)
        )
    }

    private var catalog: [Poem] {
        [
            poem("Too Short", "A Poet", lineCount: 3),
            poem("Just Right", "B Poet", lineCount: 10),
            poem("Also Right", "C Poet", lineCount: 14),
            poem("Another", "D Poet", lineCount: 20),
            poem("Too Long", "E Poet", lineCount: 60)
        ]
    }

    func test_eligiblePoems_filtersByLineCount() {
        let eligible = DailyPoemPicker.eligiblePoems(in: catalog)
        XCTAssertEqual(eligible.map(\.title), ["Just Right", "Also Right", "Another"])
    }

    func test_pick_isDeterministicForSameDate() {
        let date = Date(timeIntervalSince1970: 1_780_000_000)
        let eligible = DailyPoemPicker.eligiblePoems(in: catalog)
        let first = DailyPoemPicker.poem(for: date, in: eligible)
        let second = DailyPoemPicker.poem(for: date, in: eligible)
        XCTAssertNotNil(first)
        XCTAssertEqual(first, second)
    }

    func test_makePayload_producesConsecutiveDateKeys() {
        let start = Date(timeIntervalSince1970: 1_780_000_000)
        let payload = DailyPoemPicker.makePayload(
            catalog: catalog, from: start, days: 14, appVersion: "2.4.0"
        )
        XCTAssertEqual(payload.days.count, 14)
        let calendar = Calendar.current
        for (offset, entry) in payload.days.enumerated() {
            let expected = calendar.date(byAdding: .day, value: offset, to: start)!
            XCTAssertEqual(entry.dateKey, WidgetDateKey.string(for: expected))
        }
        // Consecutive days pick consecutive eligible poems (wrap-around mod 3).
        let titles = Set(payload.days.map(\.poem.title))
        XCTAssertEqual(titles.count, 3)
    }

    func test_excerpt_capsAtEightMeaningfulLines() {
        let entry = DailyPoemPicker.makePayload(
            catalog: [poem("Another", "D Poet", lineCount: 20)],
            from: Date(timeIntervalSince1970: 0), days: 1, appVersion: "2.4.0"
        ).days[0]
        XCTAssertEqual(entry.poem.excerptLines.count, 8)
        XCTAssertEqual(entry.poem.totalLineCount, 20)
        XCTAssertTrue(entry.poem.excerptLines.allSatisfy { $0.count >= 4 })
    }

    func test_realCatalog_hasPlentyOfEligiblePoems() throws {
        let url = try XCTUnwrap(Bundle.main.url(forResource: "PoemCatalog", withExtension: "json"))
        let catalog = try JSONDecoder().decode([Poem].self, from: Data(contentsOf: url))
        let eligible = DailyPoemPicker.eligiblePoems(in: catalog)
        XCTAssertGreaterThanOrEqual(eligible.count, 500)
    }
}

final class DeepLinkTests: XCTestCase {
    func test_poemLink_roundTripsAwkwardCharacters() throws {
        let cases: [(String, String)] = [
            ("Sonnet 1: From fairest creatures we desire increase", "William Shakespeare"),
            ("The Road to Kérity", "Charlotte Mew"),
            ("\"What Do I Care?\"", "Sara Teasdale"),
            ("Love & Friendship", "Emily Brontë"),
            ("A Poet's Song", "D. H. Lawrence")
        ]
        for (title, author) in cases {
            let link = DeepLink.poem(title: title, author: author)
            XCTAssertEqual(DeepLink(url: link.url), link, "round-trip failed for \(title)")
        }
    }

    func test_staticRoutes_roundTrip() {
        for link in [DeepLink.favorites, .support, .home] {
            XCTAssertEqual(DeepLink(url: link.url), link)
        }
    }

    func test_parser_rejectsInvalidURLs() {
        XCTAssertNil(DeepLink(url: URL(string: "https://poem?title=a&author=b")!))
        XCTAssertNil(DeepLink(url: URL(string: "poetic://unknown")!))
        XCTAssertNil(DeepLink(url: URL(string: "poetic://poem?title=OnlyTitle")!))
        XCTAssertNil(DeepLink(url: URL(string: "poetic://poem?title=&author=")!))
    }
}
