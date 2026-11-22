//
//  AppTheme.swift
//  Poetic
//
//  Created by Dean Thompson on 2026/11/22.
//

import SwiftUI
import UIKit

/// A reading theme: background, accent color and typeface. Every theme has
/// a light and a dark variant, so the existing Light / Dark / Adaptive
/// setting keeps working on top of it. Compiled into both the app and the
/// widget extension so widgets match the app.
enum AppTheme: String, CaseIterable, Identifiable {
    case paper, sepia, sage, midnight, rose, ink

    var id: String { rawValue }

    static let defaultTheme: AppTheme = .paper

    var displayName: String {
        switch self {
        case .paper: return "Paper"
        case .sepia: return "Sepia"
        case .sage: return "Sage"
        case .midnight: return "Midnight"
        case .rose: return "Rose"
        case .ink: return "Ink"
        }
    }

    /// Paper is the original look and always free; the rest are a
    /// thank-you for any tip, like the Favorites widget.
    var isFree: Bool { self == .paper }

    // MARK: - Colors

    private var accentHex: (light: UInt, dark: UInt) {
        switch self {
        case .paper: return (0x645CAA, 0xDAAFFC)
        case .sepia: return (0x8A5A2B, 0xE0B484)
        case .sage: return (0x4A7356, 0x9DCBA6)
        case .midnight: return (0x2E5A8A, 0x93BCEB)
        case .rose: return (0x9E4766, 0xEBA6BC)
        case .ink: return (0x1F1F1F, 0xF2F2F2)
        }
    }

    /// nil means the paper texture images.
    private var backgroundHex: (light: UInt, dark: UInt)? {
        switch self {
        case .paper: return nil
        case .sepia: return (0xF3EAD7, 0x241C15)
        case .sage: return (0xEDF1E8, 0x18201B)
        case .midnight: return (0xE9EEF6, 0x0E1628)
        case .rose: return (0xF8ECEE, 0x26181C)
        case .ink: return (0xFFFFFF, 0x000000)
        }
    }

    /// Cards and list rows sitting on the background.
    private var cardHex: (light: UInt, dark: UInt) {
        switch self {
        case .paper: return (0xFFFFFF, 0x000000)
        case .sepia: return (0xFBF6EA, 0x32281F)
        case .sage: return (0xF8FAF5, 0x232D27)
        case .midnight: return (0xF7F9FC, 0x19233B)
        case .rose: return (0xFEF7F8, 0x352329)
        case .ink: return (0xF3F3F3, 0x161616)
        }
    }

    func card(for scheme: ColorScheme) -> Color {
        Color(scheme == .light ? cardHex.light : cardHex.dark)
    }

    func accent(for scheme: ColorScheme) -> Color {
        Color(scheme == .light ? accentHex.light : accentHex.dark)
    }

    /// Saved-quote highlight behind poem lines.
    func highlight(for scheme: ColorScheme) -> Color {
        accent(for: scheme).opacity(0.3)
    }

    /// Solid background color, or nil when the theme uses the paper texture.
    func backgroundColor(for scheme: ColorScheme) -> Color? {
        backgroundHex.map { Color(scheme == .light ? $0.light : $0.dark) }
    }

    // MARK: - Typography

    private enum Typeface {
        /// The original look: sans-serif body, New York titles.
        case system
        case newYork
        case named(String)
    }

    /// All built into iOS, so there's nothing to bundle or license.
    private var typeface: Typeface {
        switch self {
        case .paper: return .system
        case .sepia: return .named("Baskerville")
        case .sage: return .named("Palatino-Roman")
        case .midnight: return .named("Georgia")
        case .rose: return .named("HoeflerText-Regular")
        case .ink: return .newYork
        }
    }

    /// Display titles ("Poetic." wordmark). Serif in every theme.
    func titleFont(size: CGFloat) -> UIFont {
        switch typeface {
        case .system, .newYork:
            return Self.newYork(size: size, weight: .bold)
        case .named(let name):
            return Self.named(name, size: size, bold: true)
        }
    }

    /// Poem text, author and title on the reading screen.
    func bodyFont(size: CGFloat, weight: UIFont.Weight = .medium) -> UIFont {
        switch typeface {
        case .system:
            return .systemFont(ofSize: size, weight: weight)
        case .newYork:
            return Self.newYork(size: size, weight: weight == .medium ? .regular : weight)
        case .named(let name):
            return Self.named(name, size: size, bold: weight >= .semibold)
        }
    }

    /// Widgets were always serif, so Paper keeps New York there.
    func widgetFont(size: CGFloat, bold: Bool = false) -> Font {
        switch typeface {
        case .system, .newYork:
            return .system(size: size, weight: bold ? .bold : .regular, design: .serif)
        case .named(let name):
            return Font(Self.named(name, size: size, bold: bold))
        }
    }

    private static func newYork(size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let descriptor = UIFont.systemFont(ofSize: size, weight: weight).fontDescriptor
        guard let serif = descriptor.withDesign(.serif) else {
            return UIFont(descriptor: descriptor, size: size)
        }
        return UIFont(descriptor: serif, size: size)
    }

    private static func named(_ name: String, size: CGFloat, bold: Bool) -> UIFont {
        guard let base = UIFont(name: name, size: size) else {
            return newYork(size: size, weight: bold ? .bold : .regular)
        }
        guard bold, let descriptor = base.fontDescriptor.withSymbolicTraits(.traitBold) else {
            return base
        }
        return UIFont(descriptor: descriptor, size: size)
    }
}

/// Persists the chosen theme in the App Group so the widgets can read it.
struct ThemeStore {
    private let defaults: UserDefaults

    init(defaults: UserDefaults? = nil) {
        self.defaults = defaults
            ?? UserDefaults(suiteName: SharedConstants.appGroupID)
            ?? .standard
    }

    var selected: AppTheme {
        defaults.string(forKey: SharedConstants.themeDefaultsKey)
            .flatMap(AppTheme.init(rawValue:)) ?? .defaultTheme
    }

    /// The theme to actually draw: a locked theme falls back to Paper.
    func effectiveTheme(isSupporter: Bool) -> AppTheme {
        let theme = selected
        return theme.isFree || isSupporter ? theme : .defaultTheme
    }

    func set(_ theme: AppTheme) {
        defaults.set(theme.rawValue, forKey: SharedConstants.themeDefaultsKey)
    }
}

private struct AppThemeKey: EnvironmentKey {
    static let defaultValue: AppTheme = .defaultTheme
}

extension EnvironmentValues {
    var appTheme: AppTheme {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}
