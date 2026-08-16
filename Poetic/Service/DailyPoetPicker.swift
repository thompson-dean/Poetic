//
//  DailyPoetPicker.swift
//  Poetic
//
//  Created by Dean Thompson on 2026/08/13.
//

import Foundation

enum PoetBios {
    static let all: [PoetBio] = Bundle.main.decode("PoetBios.json")

    /// Lookup by exact catalog author key. `author` is unique in the data
    /// (enforced by PoetBiosTests), so uniqueKeysWithValues is safe.
    static let byAuthor: [String: PoetBio] = Dictionary(
        uniqueKeysWithValues: all.map { ($0.author, $0) }
    )
}

/// Picks the Poet of the Day deterministically: no server, works offline,
/// and every user sees the same poet on the same day.
enum DailyPoetPicker {
    /// Stride through the alphabetical list so consecutive days don't march
    /// through poets in alphabetical order. Prime, so the cycle still visits
    /// every poet as long as the roster size isn't a multiple of 61.
    private static let stride = 61

    static func poet(for date: Date, in bios: [PoetBio], calendar: Calendar = .current) -> PoetBio? {
        guard !bios.isEmpty,
              let dayOrdinal = calendar.ordinality(of: .day, in: .era, for: date) else {
            return nil
        }
        let sorted = bios.sorted { $0.author < $1.author }
        return sorted[(dayOrdinal * stride) % sorted.count]
    }
}
