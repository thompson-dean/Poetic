//
//  WidgetPayload.swift
//  Poetic
//
//  Created by Dean Thompson on 2026/08/11.
//

import Foundation

/// A poem trimmed down for widget display. Full text never crosses the
/// app-group boundary — tapping the widget deep-links into the app.
struct WidgetPoem: Codable, Hashable {
    let title: String
    let author: String
    let excerptLines: [String]
    let totalLineCount: Int
}

struct DailyPayload: Codable, Equatable {
    struct DayEntry: Codable, Equatable {
        /// "yyyy-MM-dd" in the Gregorian calendar and the user's time zone.
        let dateKey: String
        let poem: WidgetPoem
    }

    let version: Int
    let appVersion: String
    let days: [DayEntry]

    /// Bump when the payload's contents change (v2: 20-line excerpts for the
    /// large widget; v3: rendezvous-hash daily picks) so existing payloads
    /// get rebuilt.
    static let currentVersion = 3
}

struct FavoritesPayload: Codable, Equatable {
    let version: Int
    let poems: [WidgetPoem]

    static let maximumPoems = 30
}

/// Day keys and day arithmetic for Poem of the Day. Always Gregorian with a
/// fixed locale: with the user's own calendar (e.g. Japanese), "yyyy" is the
/// era year and day counts restart each era, so keys and picks would differ
/// from everyone else's — and break if the setting changed.
enum WidgetDateKey {
    /// Recomputed each time so a time zone change is picked up.
    static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        return calendar
    }

    private static func makeFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }

    static func string(for date: Date) -> String {
        makeFormatter().string(from: date)
    }

    static func date(from key: String) -> Date? {
        makeFormatter().date(from: key)
    }
}
