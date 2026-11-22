//
//  AnalyticsEvents.swift
//  Poetic
//
//  Created by Dean Thompson on 2026/08/16.
//

import FirebaseAnalytics
import StoreKit

/// The only place Firebase Analytics is called. Every event and parameter
/// name lives here so the funnel can't drift into inconsistent strings.
/// App target only — the widget extension must stay Firebase-free.
enum AnalyticsEvents {
    // MARK: - Reading

    /// The core engagement event. `source` is where the poem was opened
    /// from: "home_recommended", "home_recent", "search", "discover",
    /// "author", "favorites", "quotes", or "deep_link".
    static func poemViewed(title: String, author: String, source: String) {
        Analytics.logEvent("poem_viewed", parameters: [
            "poem_title": String(title.prefix(90)),
            "poem_author": author,
            "source": source
        ])
    }

    static func authorViewed(author: String) {
        Analytics.logEvent("author_viewed", parameters: ["poem_author": author])
    }

    /// `surface` is "home" or "search" — measures which entry point the
    /// Poet of the Day feature actually earns its keep on.
    static func poetOfTheDayOpened(author: String, surface: String) {
        Analytics.logEvent("poet_of_the_day_opened", parameters: [
            "poem_author": author,
            "surface": surface
        ])
    }

    static func favoriteToggled(added: Bool, author: String) {
        Analytics.logEvent(added ? "favorite_added" : "favorite_removed", parameters: [
            "poem_author": author
        ])
    }

    // MARK: - Search

    /// Fires when a result is tapped, not per keystroke (every keystroke
    /// runs a search, so logging queries would flood). `type` is "poem" or
    /// "author"; `matchedLine` marks body-text hits vs title hits.
    static func searchResultOpened(type: String, matchedLine: Bool) {
        Analytics.logEvent("search_result_opened", parameters: [
            "type": type,
            "matched_line": matchedLine ? 1 : 0
        ])
    }

    // MARK: - Navigation

    static func tabSelected(_ tab: String) {
        Analytics.logEvent("tab_selected", parameters: ["tab": tab])
    }

    /// `source` is a `SettingsSource` raw value — which entry point
    /// brought the user to Settings (and the tip jar at its top).
    static func themeSelected(_ theme: String) {
        Analytics.logEvent("theme_selected", parameters: ["theme": theme])
    }

    static func settingsOpened(source: String) {
        Analytics.logEvent("settings_opened", parameters: ["source": source])
    }

    /// `type` is "home", "favorites", "support", or "poem" — every widget
    /// tap lands here, so this is the widget-engagement proxy.
    static func deepLinkOpened(type: String) {
        Analytics.logEvent("deep_link_opened", parameters: ["type": type])
    }

    // MARK: - Support / tips

    /// Fires once per Settings presentation, when the tip section actually
    /// appears — the top of the tip funnel. `source` matches settings_opened.
    static func supporterScreenViewed(source: String) {
        Analytics.logEvent("supporter_screen_viewed", parameters: ["source": source])
    }

    /// Hands a verified StoreKit 2 transaction to Firebase, which logs an
    /// `in_app_purchase` event with real price and currency. StoreKit 2
    /// purchases aren't picked up automatically, so without this GA4
    /// revenue stays at 0.
    static func logTransaction(_ transaction: Transaction) {
        Analytics.logTransaction(transaction)
    }

    // MARK: - Widget announcement

    static func widgetPromoShown() {
        Analytics.logEvent("widget_promo_shown", parameters: [:])
    }

    /// `action` is "support" or "dismiss".
    static func widgetPromoAction(action: String) {
        Analytics.logEvent("widget_promo_action", parameters: ["action": action])
    }

    static func purchaseSuccess(productID: String) {
        Analytics.logEvent("purchase_success", parameters: ["product_id": productID])
    }

    static func purchaseFailed(productID: String, reason: String) {
        Analytics.logEvent("purchase_failed", parameters: [
            "product_id": productID,
            "reason": String(reason.prefix(90))
        ])
    }

    static func purchaseCancelled(productID: String) {
        Analytics.logEvent("purchase_cancelled", parameters: ["product_id": productID])
    }

    static func restoreCompleted(unlocked: Bool) {
        Analytics.logEvent("restore_completed", parameters: ["unlocked": unlocked ? 1 : 0])
    }

    /// Fires once, the moment the widget unlock flips on — the tip funnel's
    /// conversion event.
    static func widgetUnlocked() {
        Analytics.logEvent("widget_unlocked", parameters: [:])
    }

}
