//
//  WidgetBackground.swift
//  PoeticWidgets
//
//  Created by Dean Thompson on 2026/08/11.
//

import SwiftUI

/// The selected theme's background. Paper uses its texture in light mode
/// and a near-black card in dark mode (the app's dark background image is
/// not tileable at widget sizes).
struct WidgetBackground: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        if let color = WidgetTheme.current.backgroundColor(for: colorScheme) {
            color
        } else if colorScheme == .light {
            Image("background")
                .resizable(resizingMode: .tile)
        } else {
            Color(0x1C1C1E)
        }
    }
}

extension Color {
    /// The selected theme's accent (see AppTheme).
    static func widgetTheme(for colorScheme: ColorScheme) -> Color {
        WidgetTheme.current.accent(for: colorScheme)
    }
}

enum WidgetTheme {
    /// Read fresh on every render — the app reloads timelines when the
    /// theme or supporter status changes.
    static var current: AppTheme {
        ThemeStore().effectiveTheme(isSupporter: SupporterEntitlement().isSupporter)
    }
}
