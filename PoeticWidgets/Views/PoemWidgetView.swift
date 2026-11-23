//
//  PoemWidgetView.swift
//  PoeticWidgets
//
//  Created by Dean Thompson on 2026/08/11.
//

import SwiftUI
import WidgetKit

struct PoemWidgetView: View {
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme

    let poem: WidgetPoem
    let eyebrow: String
    private let theme = WidgetTheme.current

    var body: some View {
        Group {
            switch family {
            case .accessoryRectangular:
                accessory
            case .systemSmall:
                small
            case .systemMedium:
                medium
            default:
                large
            }
        }
        .containerBackground(for: .widget) {
            WidgetBackground()
        }
    }

    private var themeColor: Color {
        Color.widgetTheme(for: colorScheme)
    }

    private var eyebrowText: some View {
        Text(eyebrow)
            .font(.system(size: 10, weight: .semibold))
            .tracking(1.2)
            .foregroundStyle(themeColor)
    }

    private var titleText: some View {
        Text(poem.title)
            .font(theme.widgetFont(size: 15, bold: true))
            .foregroundStyle(.primary)
    }

    private var authorText: some View {
        Text(poem.author)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.secondary)
    }

    /// One fixed size per widget family, so every day's poem looks the
    /// same: no per-line shrinking, no switching sizes by poem length.
    private enum LineFont {
        static let small: CGFloat = 12
        static let medium: CGFloat = 13
        static let large: CGFloat = 14
    }

    /// Title, then as many whole opening lines as fit, then the poet.
    private var small: some View {
        VStack(alignment: .leading, spacing: 3) {
            eyebrowText
            titleText
                .lineLimit(2)
            fittingExcerpt(fontSize: LineFont.small)
                .padding(.top, 2)
            authorText
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var medium: some View {
        VStack(alignment: .leading, spacing: 4) {
            eyebrowText
            titleText
                .lineLimit(2)
            authorText
                .lineLimit(1)
            fittingExcerpt(fontSize: LineFont.medium)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var large: some View {
        VStack(alignment: .leading, spacing: 6) {
            eyebrowText
            titleText
                .lineLimit(2)
            authorText
                .lineLimit(1)
            HStack(alignment: .top, spacing: 8) {
                RoundedRectangle(cornerRadius: 1)
                    .foregroundStyle(themeColor)
                    .frame(width: 2)
                fittingExcerpt(fontSize: LineFont.large)
            }
            .padding(.top, 4)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    /// The excerpt stops before the poem does (the payload carries at most
    /// 20 lines), so a "…" belongs at the end even if every line fits.
    private var poemContinues: Bool {
        poem.excerptLines.count >= 20 && poem.totalLineCount > poem.excerptLines.count
    }

    /// As many whole poem lines as fit the space left, measured at the real
    /// widget width: long lines wrap instead of being cut off with "…", and
    /// a line that doesn't fit completely is left out (FittingLinesLayout).
    private func fittingExcerpt(fontSize: CGFloat) -> some View {
        FittingLinesLayout(spacing: 2, poemContinues: poemContinues) {
            ForEach(Array(poem.excerptLines.enumerated()), id: \.offset) { _, line in
                Text(line)
                    .font(theme.widgetFont(size: fontSize))
                    .foregroundStyle(.primary.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Text("…")
                .font(theme.widgetFont(size: fontSize))
                .foregroundStyle(.secondary)
                .layoutValue(key: IsMoreMarker.self, value: true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .clipped()
    }

    private var accessory: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(poem.title)
                .font(.system(size: 13, weight: .bold, design: .serif))
                .lineLimit(1)
            Text(poem.author)
                .font(.system(size: 11))
                .lineLimit(1)
            if let first = poem.excerptLines.first {
                Text(first)
                    .font(.system(size: 11, design: .serif))
                    .lineLimit(1)
            }
        }
        .widgetAccentable()
    }
}

struct LockedFavoritesView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "lock.fill")
                .font(.system(size: 22))
                .foregroundStyle(Color.widgetTheme(for: colorScheme))
            Text("Your favorites, on your home screen")
                .font(.system(size: 13, weight: .semibold))
                .multilineTextAlignment(.center)
            Text("Leave any tip in Poetic to unlock")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .containerBackground(for: .widget) {
            WidgetBackground()
        }
    }
}

struct EmptyFavoritesView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "star")
                .font(.system(size: 22))
                .foregroundStyle(Color.widgetTheme(for: colorScheme))
            Text("No favorites yet")
                .font(.system(size: 13, weight: .semibold))
            Text("Star a poem in Poetic")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
        .containerBackground(for: .widget) {
            WidgetBackground()
        }
    }
}

struct SetupNeededView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: "book")
                .font(.system(size: 22))
                .foregroundStyle(Color.widgetTheme(for: colorScheme))
            Text("Open Poetic to get started")
                .font(.system(size: 13, weight: .semibold))
                .multilineTextAlignment(.center)
        }
        .containerBackground(for: .widget) {
            WidgetBackground()
        }
    }
}
