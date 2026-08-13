//
//  FavoritesWidget.swift
//  PoeticWidgets
//
//  Created by Dean Thompson on 2026/08/11.
//

import WidgetKit
import SwiftUI

struct FavoritesEntry: TimelineEntry {
    enum State {
        case locked
        case empty
        case poem(WidgetPoem)
    }

    let date: Date
    let state: State
}

struct FavoritesProvider: TimelineProvider {
    private let store = WidgetDataStore.live

    func placeholder(in context: Context) -> FavoritesEntry {
        FavoritesEntry(date: Date(), state: .poem(.placeholder))
    }

    func getSnapshot(in context: Context, completion: @escaping (FavoritesEntry) -> Void) {
        completion(FavoritesEntry(date: Date(), state: currentState(index: 0)))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<FavoritesEntry>) -> Void) {
        let now = Date()
        guard SupporterEntitlement().isSupporter else {
            // Re-check periodically so unlocking updates without an app launch.
            let timeline = Timeline(
                entries: [FavoritesEntry(date: now, state: .locked)],
                policy: .after(now.addingTimeInterval(4 * 3600))
            )
            completion(timeline)
            return
        }

        let poems = store.readFavorites()?.poems ?? []
        guard !poems.isEmpty else {
            let timeline = Timeline(
                entries: [FavoritesEntry(date: now, state: .empty)],
                policy: .after(now.addingTimeInterval(4 * 3600))
            )
            completion(timeline)
            return
        }

        // Rotate through favorites hourly for the next 24 hours.
        let calendar = Calendar.current
        let hourOfEra = calendar.ordinality(of: .hour, in: .era, for: now) ?? 0
        var entries = [FavoritesEntry]()
        let topOfHour = calendar.dateInterval(of: .hour, for: now)?.start ?? now
        for offset in 0..<24 {
            let date = offset == 0 ? now : topOfHour.addingTimeInterval(TimeInterval(offset) * 3600)
            let poem = poems[(hourOfEra + offset) % poems.count]
            entries.append(FavoritesEntry(date: date, state: .poem(poem)))
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }

    private func currentState(index: Int) -> FavoritesEntry.State {
        guard SupporterEntitlement().isSupporter else { return .locked }
        let poems = store.readFavorites()?.poems ?? []
        guard !poems.isEmpty else { return .empty }
        return .poem(poems[index % poems.count])
    }
}

struct FavoritesWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: SharedConstants.favoritesWidgetKind,
            provider: FavoritesProvider()
        ) { entry in
            switch entry.state {
            case .poem(let poem):
                PoemWidgetView(poem: poem, eyebrow: "FROM YOUR FAVORITES")
                    .widgetURL(DeepLink.poem(title: poem.title, author: poem.author).url)
            case .locked:
                LockedFavoritesView()
                    .widgetURL(DeepLink.support.url)
            case .empty:
                EmptyFavoritesView()
                    .widgetURL(DeepLink.favorites.url)
            }
        }
        .configurationDisplayName("Favorites")
        .description("Your favorite poems, rotating through the day. A supporter perk.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
