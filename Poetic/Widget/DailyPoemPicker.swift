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
    var asWidgetPoem: WidgetPoem {
        WidgetPoem(
            title: title,
            author: author,
            excerptLines: PoemExcerpt.lines(from: lines, limit: 8),
            totalLineCount: lines.count
        )
    }
}

/// Picks the Poem of the Day deterministically from the catalog: no server,
/// works offline, and every user sees the same poem on the same day.
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

    static func poem(for date: Date, in eligible: [Poem], calendar: Calendar = .current) -> Poem? {
        guard !eligible.isEmpty,
              let dayOrdinal = calendar.ordinality(of: .day, in: .era, for: date) else {
            return nil
        }
        return eligible[dayOrdinal % eligible.count]
    }

    static func makePayload(
        catalog: [Poem],
        from startDate: Date = Date(),
        days: Int = 14,
        appVersion: String,
        calendar: Calendar = .current
    ) -> DailyPayload {
        let eligible = eligiblePoems(in: catalog)
        var entries = [DailyPayload.DayEntry]()
        for offset in 0..<days {
            guard let date = calendar.date(byAdding: .day, value: offset, to: startDate),
                  let poem = poem(for: date, in: eligible, calendar: calendar) else { continue }
            entries.append(
                DailyPayload.DayEntry(dateKey: WidgetDateKey.string(for: date), poem: poem.asWidgetPoem)
            )
        }
        return DailyPayload(version: 1, appVersion: appVersion, days: entries)
    }
}
