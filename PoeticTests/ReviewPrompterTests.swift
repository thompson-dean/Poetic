//
//  ReviewPrompterTests.swift
//  PoeticTests
//
//  Created by Dean Thompson on 2026/11/22.
//

import XCTest
@testable import Poetic

final class ReviewPrompterTests: XCTestCase {
    private var defaults: UserDefaults!
    private let suiteName = "ReviewPrompterTests"
    private let day: TimeInterval = 86_400

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    private func prompter(version: String = "3.1.0") -> ReviewPrompter {
        ReviewPrompter(defaults: defaults, appVersion: version)
    }

    /// A loyal user: poems opened on three separate days.
    private func makeLoyal(_ prompter: ReviewPrompter) {
        let start = Date(timeIntervalSince1970: 1_800_000_000)
        for offset in 0..<ReviewPrompter.minimumActiveDays {
            prompter.recordPoemOpened(on: start.addingTimeInterval(Double(offset) * day))
        }
    }

    private func happyMoment(_ prompter: ReviewPrompter) -> Bool {
        prompter.shouldPrompt(poemIsFavorited: true, secondsOnPoem: 30, favoritesCount: 3)
    }

    func test_loyalUserLeavingFavoritedPoem_isPrompted() {
        let prompter = prompter()
        makeLoyal(prompter)
        XCTAssertTrue(happyMoment(prompter))
    }

    func test_manyPoemsOnOneDay_countsAsOneActiveDay() {
        let prompter = prompter()
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        for minute in 0..<50 {
            prompter.recordPoemOpened(on: now.addingTimeInterval(Double(minute) * 60))
        }
        XCTAssertEqual(prompter.activeDays, 1)
        XCTAssertFalse(happyMoment(prompter))
    }

    func test_poemNotFavorited_isNotPrompted() {
        let prompter = prompter()
        makeLoyal(prompter)
        XCTAssertFalse(prompter.shouldPrompt(poemIsFavorited: false, secondsOnPoem: 30, favoritesCount: 10))
    }

    func test_quickBounce_isNotPrompted() {
        let prompter = prompter()
        makeLoyal(prompter)
        XCTAssertFalse(prompter.shouldPrompt(poemIsFavorited: true, secondsOnPoem: 5, favoritesCount: 10))
    }

    func test_tooFewFavorites_isNotPrompted() {
        let prompter = prompter()
        makeLoyal(prompter)
        XCTAssertFalse(prompter.shouldPrompt(poemIsFavorited: true, secondsOnPoem: 30, favoritesCount: 2))
    }

    func test_promptsOncePerVersion() {
        let prompter = prompter()
        makeLoyal(prompter)
        prompter.markPrompted()
        XCTAssertFalse(happyMoment(prompter))
        XCTAssertTrue(happyMoment(self.prompter(version: "3.2.0")))
    }
}
