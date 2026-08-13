//
//  PoemOfTheDayWidget.swift
//  PoeticWidgets
//
//  Created by Dean Thompson on 2026/08/11.
//

import WidgetKit
import SwiftUI

struct DailyPoemEntry: TimelineEntry {
    let date: Date
    let poem: WidgetPoem?
}

struct PoemOfTheDayProvider: TimelineProvider {
    private let store = WidgetDataStore.live

    func placeholder(in context: Context) -> DailyPoemEntry {
        DailyPoemEntry(date: Date(), poem: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (DailyPoemEntry) -> Void) {
        let todayKey = WidgetDateKey.string(for: Date())
        let poem = store.readDaily()?.days.first { $0.dateKey == todayKey }?.poem
        completion(DailyPoemEntry(date: Date(), poem: poem ?? .placeholder))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DailyPoemEntry>) -> Void) {
        let now = Date()
        let calendar = Calendar.current
        let todayKey = WidgetDateKey.string(for: now)

        guard let payload = store.readDaily() else {
            // The app hasn't written data yet — show the setup state and retry.
            let timeline = Timeline(
                entries: [DailyPoemEntry(date: now, poem: nil)],
                policy: .after(now.addingTimeInterval(3600))
            )
            completion(timeline)
            return
        }

        var entries = [DailyPoemEntry]()
        for entry in payload.days where entry.dateKey >= todayKey {
            if entry.dateKey == todayKey {
                entries.append(DailyPoemEntry(date: now, poem: entry.poem))
            } else if let date = dateFromKey(entry.dateKey, calendar: calendar) {
                entries.append(DailyPoemEntry(date: calendar.startOfDay(for: date), poem: entry.poem))
            }
        }
        if entries.isEmpty {
            entries = [DailyPoemEntry(date: now, poem: nil)]
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }

    private func dateFromKey(_ key: String, calendar: Calendar) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = calendar
        return formatter.date(from: key)
    }
}

struct PoemOfTheDayWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: SharedConstants.dailyWidgetKind,
            provider: PoemOfTheDayProvider()
        ) { entry in
            if let poem = entry.poem {
                PoemWidgetView(poem: poem, eyebrow: "POEM OF THE DAY")
                    .widgetURL(DeepLink.poem(title: poem.title, author: poem.author).url)
            } else {
                SetupNeededView()
                    .widgetURL(DeepLink.home.url)
            }
        }
        .configurationDisplayName("Poem of the Day")
        .description("A new poem on your home screen every day.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryRectangular])
    }
}

extension WidgetPoem {
    static let placeholder = WidgetPoem(
        title: "Sonnet 18: Shall I compare thee to a summer's day?",
        author: "William Shakespeare",
        excerptLines: [
            "Shall I compare thee to a summer's day?",
            "Thou art more lovely and more temperate:",
            "Rough winds do shake the darling buds of May,",
            "And summer's lease hath all too short a date:"
        ],
        totalLineCount: 14
    )
}
