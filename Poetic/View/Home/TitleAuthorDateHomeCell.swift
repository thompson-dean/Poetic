//
//  TitleAuthorDateHomeCell.swift
//  Poetic
//
//  Created by Dean Thompson on 2023/02/13.
//

import SwiftUI

struct TitleAuthorDateHomeCell: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.appTheme) private var theme
    let poem: PoemEntity

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(poem.author)
                            .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 24)
                            .foregroundColor(.primary)

                        Spacer()

                        Text(poem.lastViewedAt?.formatted(date: .abbreviated, time: .omitted) ?? "")
                            .fontWithLineHeight(font: .systemFont(ofSize: 12, weight: .light), lineHeight: 8)
                            .foregroundColor(.primary.opacity(0.5))
                    }

                    Text(poem.title)
                        .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .semibold), lineHeight: 24)
                        .foregroundColor(theme.accent(for: colorScheme))
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 8)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.primary)
                    .padding(8)
            }
        }
        .background(theme.card(for: colorScheme))
        .cornerRadius(8)
        .padding(.horizontal, 8)    }
}
