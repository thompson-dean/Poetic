//
//  PoetBiosTests.swift
//  PoeticTests
//
//  Created by Dean Thompson on 2026/08/13.
//

import XCTest
@testable import Poetic

final class PoetBiosTests: XCTestCase {
    private static let authors: Authors = Bundle.main.decode("Authors.json")

    // MARK: - Bio data integrity

    func testEveryCatalogAuthorHasExactlyOneBio() {
        let bioAuthors = PoetBios.all.map(\.author)
        let missing = Set(Self.authors.authors).subtracting(bioAuthors)
        let extra = Set(bioAuthors).subtracting(Self.authors.authors)

        XCTAssertTrue(missing.isEmpty, "Authors without a bio: \(missing.sorted())")
        XCTAssertTrue(extra.isEmpty, "Bios for unknown authors: \(extra.sorted())")
        XCTAssertEqual(bioAuthors.count, Set(bioAuthors).count, "Duplicate bio entries")
    }

    func testBioFieldsAreWellFormed() {
        for bio in PoetBios.all {
            XCTAssertFalse(bio.blurb.isEmpty, "\(bio.author) has an empty blurb")
            XCTAssertTrue(bio.years.contains("–"), "\(bio.author) years missing en dash: \(bio.years)")
            if let displayName = bio.displayName {
                XCTAssertFalse(displayName.isEmpty, "\(bio.author) has an empty display name")
            }
        }
    }

    // MARK: - Daily picker

    func testPickerIsDeterministicForSameDate() {
        let calendar = Calendar(identifier: .gregorian)
        let date = Date(timeIntervalSince1970: 1_770_000_000)
        let first = DailyPoetPicker.poet(for: date, in: PoetBios.all, calendar: calendar)
        let second = DailyPoetPicker.poet(for: date, in: PoetBios.all, calendar: calendar)

        XCTAssertNotNil(first)
        XCTAssertEqual(first, second)
    }

    func testPickerVisitsEveryPoetOverFullCycle() throws {
        let bios = PoetBios.all
        let calendar = Calendar(identifier: .gregorian)
        let start = Date(timeIntervalSince1970: 1_770_000_000)

        var seen = Set<String>()
        for offset in 0..<bios.count {
            let date = try XCTUnwrap(calendar.date(byAdding: .day, value: offset, to: start))
            let poet = try XCTUnwrap(DailyPoetPicker.poet(for: date, in: bios, calendar: calendar))
            seen.insert(poet.author)
        }

        XCTAssertEqual(seen.count, bios.count, "Rotation should visit every poet before repeating")
    }

    func testPickerReturnsNilForEmptyRoster() {
        XCTAssertNil(DailyPoetPicker.poet(for: Date(), in: []))
    }
}
