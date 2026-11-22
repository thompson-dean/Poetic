//
//  ReviewPrompter.swift
//  Poetic
//
//  Created by Dean Thompson on 2026/11/22.
//

import Foundation

/// Decides when to ask for an App Store rating. We can't ask "do you like
/// the app?" first (review gating breaks App Store guidelines), so instead
/// we only ask at a moment of clear delight from someone who keeps coming
/// back:
///
/// - they're leaving a poem they've favorited,
/// - after actually reading it (20+ seconds),
/// - they've used Poetic on 3+ different days,
/// - they have 3+ favorites,
/// - and they haven't been asked during this app version.
///
/// iOS additionally caps the system prompt at three per year.
struct ReviewPrompter {
    static let minimumActiveDays = 3
    static let minimumFavorites = 3
    static let minimumSecondsOnPoem: TimeInterval = 20

    private enum Key {
        static let activeDays = "review.activeDays"
        static let lastActiveDay = "review.lastActiveDay"
        static let lastPromptedVersion = "review.lastPromptedVersion"
    }

    private let defaults: UserDefaults
    private let appVersion: String

    init(
        defaults: UserDefaults = .standard,
        appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0"
    ) {
        self.defaults = defaults
        self.appVersion = appVersion
    }

    /// Counts distinct calendar days the user opened a poem on.
    func recordPoemOpened(on date: Date = Date()) {
        let today = WidgetDateKey.string(for: date)
        guard defaults.string(forKey: Key.lastActiveDay) != today else { return }
        defaults.set(today, forKey: Key.lastActiveDay)
        defaults.set(activeDays + 1, forKey: Key.activeDays)
    }

    var activeDays: Int {
        defaults.integer(forKey: Key.activeDays)
    }

    var hasPromptedThisVersion: Bool {
        defaults.string(forKey: Key.lastPromptedVersion) == appVersion
    }

    /// Called as the user leaves a poem.
    func shouldPrompt(
        poemIsFavorited: Bool,
        secondsOnPoem: TimeInterval,
        favoritesCount: Int
    ) -> Bool {
        poemIsFavorited
            && secondsOnPoem >= Self.minimumSecondsOnPoem
            && activeDays >= Self.minimumActiveDays
            && favoritesCount >= Self.minimumFavorites
            && !hasPromptedThisVersion
    }

    func markPrompted() {
        defaults.set(appVersion, forKey: Key.lastPromptedVersion)
    }
}
