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
            .font(.system(size: 15, weight: .bold, design: .serif))
            .foregroundStyle(.primary)
    }

    private var authorText: some View {
        Text(poem.author)
            .font(.system(size: 11, weight: .medium))
            .foregroundStyle(.secondary)
    }

    private var small: some View {
        VStack(alignment: .leading, spacing: 4) {
            eyebrowText
            titleText
                .lineLimit(3)
            Spacer(minLength: 0)
            authorText
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var medium: some View {
        VStack(alignment: .leading, spacing: 4) {
            eyebrowText
            titleText
                .lineLimit(2)
            authorText
                .lineLimit(1)
            Spacer(minLength: 2)
            excerpt(lineLimit: 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
                excerpt(lineLimit: 7)
            }
            .padding(.top, 4)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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

    private func excerpt(lineLimit: Int) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(Array(poem.excerptLines.prefix(lineLimit).enumerated()), id: \.offset) { _, line in
                Text(line)
                    .font(.system(size: 13, design: .serif))
                    .foregroundStyle(.primary.opacity(0.85))
                    .lineLimit(1)
            }
            if poem.totalLineCount > lineLimit {
                Text("…")
                    .font(.system(size: 13, design: .serif))
                    .foregroundStyle(.secondary)
            }
        }
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
