//
//  AuthorPoemCell.swift
//  Poetic
//
//  Created by Dean Thompson on 2023/02/14.
//

import SwiftUI

struct AuthorPoemCell: View {
    @Environment(\.colorScheme) var colorScheme
    let poem: Poem
    let indexString: String

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {

                        Text("\(indexString).")
                            .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 24)
                            .foregroundColor(colorScheme == .light ? .lightThemeColor : .darkThemeColor)

                        Text(poem.title)
                            .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 24)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)

                        Spacer()
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
        .frame(width: UIScreen.main.bounds.width - 16)
        .background(colorScheme == .light ? .white : .black)
        .cornerRadius(8)
        .padding(.horizontal, 8)
    }
}
