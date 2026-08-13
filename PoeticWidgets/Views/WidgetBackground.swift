//
//  WidgetBackground.swift
//  PoeticWidgets
//
//  Created by Dean Thompson on 2026/08/11.
//

import SwiftUI

/// The app's paper texture in light mode; a near-black card in dark mode
/// (the app's dark background image is not tileable at widget sizes).
struct WidgetBackground: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        if colorScheme == .light {
            Image("background")
                .resizable(resizingMode: .tile)
        } else {
            Color(0x1C1C1E)
        }
    }
}

extension Color {
    /// Matches the app's theme accent (Extensions/Color.swift).
    static var widgetTheme: Color {
        Color.lightThemeColor
    }

    static func widgetTheme(for colorScheme: ColorScheme) -> Color {
        colorScheme == .light ? .lightThemeColor : .darkThemeColor
    }
}
