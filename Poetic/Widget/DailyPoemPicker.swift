//
//  DailyPoemPicker.swift
//  Poetic
//
//  Created by Dean Thompson on 2026/08/11.
//

import Foundation

// App target only — this file touches the full catalog, which must never
// be loaded inside the widget extension.

extension Poem {
    /// Enough lines to fill a large widget at its smallest font size; the
    /// widget view picks how many it can actually fit.
    static let widgetExcerptLimit = 20

    var asWidgetPoem: WidgetPoem {
        WidgetPoem(
            title: title,
            author: author,
            excerptLines: PoemExcerpt.lines(from: lines, limit: Self.widgetExcerptLimit),
            totalLineCount: lines.count
        )
    }
}

/// Picks the Poem of the Day deterministically from the catalog: no server,
/// works offline, and every user sees the same poem on the same day.
///
/// Uses rendezvous (highest-random-weight) hashing: each eligible poem gets
/// a score from hashing "title|author|yyyy-MM-dd", and the highest score
/// wins. Adding poems to the catalog only changes a day if a new poem
/// happens to win it (about 1 day in N), so growing the catalog doesn't
/// reshuffle everyone's upcoming Poems of the Day the way `day % count` did.
enum DailyPoemPicker {
    static let minimumLines = 6
    static let maximumLines = 24

    static func eligiblePoems(in catalog: [Poem]) -> [Poem] {
        catalog
            .filter { (minimumLines...maximumLines).contains($0.lines.count) }
            .sorted {
                if $0.author != $1.author { return $0.author < $1.author }
                return $0.title < $1.title
            }
    }

    static func poem(for date: Date, in eligible: [Poem]) -> Poem? {
        poem(forDayKey: WidgetDateKey.string(for: date), in: eligible)
    }

    static func poem(forDayKey dayKey: String, in eligible: [Poem]) -> Poem? {
        let day = Array(dayKey.utf8)
        var best: Poem?
        var bestScore: UInt64 = 0
        for poem in eligible {
            let score = StableHash.score(poemKey: "\(poem.title)|\(poem.author)|", day: day)
            // Ties (astronomically unlikely) break on the sorted order.
            if best == nil || score > bestScore {
                best = poem
                bestScore = score
            }
        }
        return best
    }

    static func makePayload(
        catalog: [Poem],
        from startDate: Date = Date(),
        days: Int = 90,
        appVersion: String,
        calendar: Calendar = WidgetDateKey.calendar
    ) -> DailyPayload {
        let eligible = eligiblePoems(in: catalog)
        var entries = [DailyPayload.DayEntry]()
        for offset in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: offset, to: startDate),
                  let poem = poem(for: date, in: eligible) else { continue }
            entries.append(
                DailyPayload.DayEntry(dateKey: WidgetDateKey.string(for: date), poem: poem.asWidgetPoem)
            )
        }
        return DailyPayload(version: DailyPayload.currentVersion, appVersion: appVersion, days: entries)
    }
}

/// FNV-1a 64-bit over UTF-8 bytes, finished with a SplitMix64 mix so that
/// keys differing only in their last characters (consecutive dates) still
/// get well-spread scores. Pure arithmetic: identical on every device and
/// OS version, unlike `Hasher`, which is randomly seeded per launch.
enum StableHash {
    static func score(poemKey: String, day: [UInt8]) -> UInt64 {
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in poemKey.utf8 {
            hash = (hash ^ UInt64(byte)) &* 0x100000001b3
        }
        for byte in day {
            hash = (hash ^ UInt64(byte)) &* 0x100000001b3
        }
        return mix(hash)
    }

    static func mix(_ value: UInt64) -> UInt64 {
        var mixed = value &+ 0x9e3779b97f4a7c15
        mixed = (mixed ^ (mixed >> 30)) &* 0xbf58476d1ce4e5b9
        mixed = (mixed ^ (mixed >> 27)) &* 0x94d049bb133111eb
        return mixed ^ (mixed >> 31)
    }
}
