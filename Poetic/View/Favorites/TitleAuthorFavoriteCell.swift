//
//  TitleAuthorFavoriteCell.swift
//  Poetic
//
//  Created by Dean Thompson on 2023/02/13.
//

import SwiftUI

struct TitleAuthorFavoriteCell: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.appTheme) private var theme
    let poem: PoemEntity

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {

                    Text(poem.author)
                        .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 24)
                        .foregroundColor(.primary)

                    Text(poem.title)
                        .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .semibold), lineHeight: 24)
                        .foregroundColor(theme.accent(for: colorScheme))
                }
                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
        }
        .background(theme.card(for: colorScheme))
        .cornerRadius(8)
        .padding(.vertical, 4)
    }
}
