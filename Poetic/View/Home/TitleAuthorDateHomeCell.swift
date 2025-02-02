//
//  TitleAuthorDateHomeCell.swift
//  Poetic
//
//  Created by Dean Thompson on 2023/02/13.
//

import SwiftUI

struct TitleAuthorDateHomeCell: View {
    @ObservedObject var pcViewModel: PersistenceController
    @Environment(\.colorScheme) var colorScheme
    let poem: ViewedPoemEntity

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(poem.author ?? "")
                            .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 24)
                            .foregroundColor(.primary)

                        Spacer()

                        Text(pcViewModel.convertDateToString(date: poem.date))
                            .fontWithLineHeight(font: .systemFont(ofSize: 12, weight: .light), lineHeight: 8)
                            .foregroundColor(.primary.opacity(0.5))
                    }

                    Text(poem.title ?? "")
                        .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .semibold), lineHeight: 24)
                        .foregroundColor(colorScheme == .light ? .lightThemeColor : .darkThemeColor)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 8)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.primary)
                    .padding(8)
            }
        }
        .background(colorScheme == .light ? .white : .black)
        .cornerRadius(8)
        .padding(.horizontal, 8)    }
}
