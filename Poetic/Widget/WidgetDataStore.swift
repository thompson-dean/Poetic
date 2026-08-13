//
//  WidgetDataStore.swift
//  Poetic
//
//  Created by Dean Thompson on 2026/08/11.
//

import Foundation

/// Reads and writes the small JSON payloads the widgets consume, inside the
/// shared App Group container. When the container is unavailable (the App
/// Group capability hasn't been registered yet), writes silently no-op and
/// reads return nil — the app behaves normally and widgets show their
/// "open the app" placeholder.
struct WidgetDataStore {
    private let directoryURL: URL?

    init(containerURL: URL?) {
        directoryURL = containerURL?.appendingPathComponent("WidgetData", isDirectory: true)
    }

    static let live = WidgetDataStore(
        containerURL: FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: SharedConstants.appGroupID
        )
    )

    // MARK: - Daily

    func writeDaily(_ payload: DailyPayload) {
        write(payload, to: "daily.json")
    }

    func readDaily() -> DailyPayload? {
        read("daily.json")
    }

    // MARK: - Favorites

    func writeFavorites(_ payload: FavoritesPayload) {
        let capped = FavoritesPayload(
            version: payload.version,
            poems: Array(payload.poems.prefix(FavoritesPayload.maximumPoems))
        )
        write(capped, to: "favorites.json")
    }

    func readFavorites() -> FavoritesPayload? {
        read("favorites.json")
    }

    // MARK: - Internals

    private func write<T: Encodable>(_ value: T, to filename: String) {
        guard let directoryURL else { return }
        do {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(value)
            try data.write(to: directoryURL.appendingPathComponent(filename), options: .atomic)
        } catch {
            print("WidgetDataStore write failed: \(error.localizedDescription)")
        }
    }

    private func read<T: Decodable>(_ filename: String) -> T? {
        guard let directoryURL,
              let data = try? Data(contentsOf: directoryURL.appendingPathComponent(filename)) else {
            return nil
        }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
