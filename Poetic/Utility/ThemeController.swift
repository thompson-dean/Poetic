//
//  ThemeController.swift
//  Poetic
//
//  Created by Dean Thompson on 2026/11/22.
//

import SwiftUI
import WidgetKit

/// Owns the selected theme for the running app. Views read the theme from
/// `@Environment(\.appTheme)`; Settings uses this object to change it.
@MainActor
final class ThemeController: ObservableObject {
    @Published private(set) var selected: AppTheme

    private let store: ThemeStore

    init(store: ThemeStore = ThemeStore()) {
        self.store = store
        self.selected = store.selected
    }

    /// The theme to draw, given current supporter status.
    func effectiveTheme(isSupporter: Bool) -> AppTheme {
        store.effectiveTheme(isSupporter: isSupporter)
    }

    func select(_ theme: AppTheme) {
        guard theme != selected else { return }
        selected = theme
        store.set(theme)
        AnalyticsEvents.themeSelected(theme.rawValue)
        WidgetCenter.shared.reloadAllTimelines()
    }
}

/// The screen background for the current theme: the paper texture for
/// Paper, a solid color for everything else.
struct ThemeBackgroundView: View {
    @Environment(\.appTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        if let color = theme.backgroundColor(for: colorScheme) {
            color
        } else {
            Image(colorScheme == .light ? "background" : "background-dark")
                .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
        }
    }
}
