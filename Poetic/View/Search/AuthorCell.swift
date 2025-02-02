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

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 2) {

                    Text(author)
                        .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 24)
                        .foregroundColor(.primary)
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
