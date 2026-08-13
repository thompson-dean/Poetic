//
//  WidgetDataRefresher.swift
//  Poetic
//
//  Created by Dean Thompson on 2026/08/11.
//

import Foundation
import WidgetKit

// App target only — loads the full catalog.

/// Keeps the widgets' App Group payloads fresh.
struct WidgetDataRefresher {
    private let service: PoemServiceProtocol
    private let store: WidgetDataStore
    private let appVersion: String

    init(
        service: PoemServiceProtocol,
        store: WidgetDataStore = .live,
        appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
    ) {
        self.service = service
        self.store = store
        self.appVersion = appVersion
    }

    /// Rebuilds the 14-day daily payload when it's stale (covers fewer than
    /// 7 days from today) or was written by a different app version.
    func refreshDailyIfNeeded(now: Date = Date()) async {
        if let existing = store.readDaily(), existing.appVersion == appVersion {
            let today = WidgetDateKey.string(for: now)
            let remaining = existing.days.drop { $0.dateKey < today }
            if remaining.count >= 7 {
                return
            }
        }
        guard let catalog = try? await service.allPoems() else {
            return
        }
        let payload = DailyPoemPicker.makePayload(catalog: catalog, from: now, appVersion: appVersion)
        guard !payload.days.isEmpty else { return }
        store.writeDaily(payload)
        WidgetCenter.shared.reloadTimelines(ofKind: SharedConstants.dailyWidgetKind)
    }
}

/// Receives favorites changes from PoemStore and mirrors them into the
/// App Group for the Favorites widget.
protocol WidgetFavoritesSyncing {
    func favoritesDidChange(_ favorites: [Poem])
}

struct LiveWidgetFavoritesSync: WidgetFavoritesSyncing {
    let store: WidgetDataStore

    init(store: WidgetDataStore = .live) {
        self.store = store
    }

    func favoritesDidChange(_ favorites: [Poem]) {
        store.writeFavorites(
            FavoritesPayload(version: 1, poems: favorites.map(\.asWidgetPoem))
        )
        WidgetCenter.shared.reloadTimelines(ofKind: SharedConstants.favoritesWidgetKind)
    }
}
