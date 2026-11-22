//
//  TodaysPoemCard.swift
//  Poetic
//
//  Created by Dean Thompson on 2026/11/22.
//

import SwiftUI

/// The top of Home: today's poem (the same one the Poem of the Day widget
/// shows), with its opening lines and an invitation to read. Gives new users
/// an obvious first tap without opening a poem for them.
struct TodaysPoemCard: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.appTheme) private var theme
    let poem: Poem

    private var excerpt: [String] {
        PoemExcerpt.lines(from: poem.lines, limit: 4)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(poem.title)
                .font(Font(theme.titleFont(size: 22)))
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Text(poem.author)
                .fontWithLineHeight(font: .systemFont(ofSize: 15, weight: .semibold), lineHeight: 18)
                .foregroundColor(.secondary)

            HStack(alignment: .top, spacing: 10) {
                RoundedRectangle(cornerRadius: 1)
                    .fill(theme.accent(for: colorScheme))
                    .frame(width: 2)
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(excerpt.enumerated()), id: \.offset) { _, line in
                        Text(line)
                            .fontWithLineHeight(font: theme.bodyFont(size: 16), lineHeight: 20)
                            .foregroundColor(.primary.opacity(0.85))
                            .lineLimit(1)
                    }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.vertical, 4)

            HStack(spacing: 4) {
                Text("Read today's poem")
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
            }
            .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .semibold), lineHeight: 24)
            .foregroundColor(theme.accent(for: colorScheme))
        }
        // 8 + 8 puts the text on the same 16pt line as the section headings,
        // matching the other Home cards.
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(theme.card(for: colorScheme))
        .cornerRadius(8)
        .padding(.horizontal, 8)
        .accessibilityElement(children: .combine)
        .accessibilityHint("Opens today's poem")
    }
}
