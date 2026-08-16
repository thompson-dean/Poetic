//
//  AuthorCell.swift
//  Poetic
//
//  Created by Dean Thompson on 2023/02/14.
//

import SwiftUI

struct AuthorCell: View {
    @Environment(\.colorScheme) var colorScheme
    let author: String
    var badge: String?

    private var bio: PoetBio? { PoetBios.byAuthor[author] }

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    if let badge {
                        Text(badge)
                            .fontWithLineHeight(font: .systemFont(ofSize: 12, weight: .semibold), lineHeight: 16)
                            .foregroundColor(colorScheme == .light ? .lightThemeColor : .darkThemeColor)
                    }

                    Text(bio?.name ?? author)
                        .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 24)
                        .foregroundColor(.primary)

                    if let years = bio?.years {
                        Text(years)
                            .fontWithLineHeight(font: .systemFont(ofSize: 14, weight: .medium), lineHeight: 20)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 8)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.primary)
                    .padding(8)
            }
        }
        .frame(maxWidth: .infinity)
        .background(colorScheme == .light ? .white : .black)
        .cornerRadius(8)
        .padding(.horizontal, 8)
    }
}
