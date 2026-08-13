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
        /// "yyyy-MM-dd" in the user's current calendar and time zone.
        let dateKey: String
        let poem: WidgetPoem
    }

    let version: Int
    let appVersion: String
    let days: [DayEntry]
}

struct FavoritesPayload: Codable, Equatable {
    let version: Int
    let poems: [WidgetPoem]

    static let maximumPoems = 30
}

enum WidgetDateKey {
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static func string(for date: Date) -> String {
        formatter.string(from: date)
    }
}
