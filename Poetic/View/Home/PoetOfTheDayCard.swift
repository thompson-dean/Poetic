//
//  PoetOfTheDayCard.swift
//  Poetic
//
//  Created by Dean Thompson on 2026/08/13.
//

import SwiftUI

struct PoetOfTheDayCard: View {
    @Environment(\.colorScheme) var colorScheme
    let bio: PoetBio

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                nameText
                Spacer()
                yearsText
            }
            blurbText
            footer
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackgroundColor)
        .cornerRadius(8)
        .padding(.horizontal, 16)
    }

    private var nameText: some View {
        Text(bio.name)
            .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 20)
            .foregroundColor(.primary)
    }

    private var yearsText: some View {
        Text(bio.years)
            .fontWithLineHeight(font: .systemFont(ofSize: 14, weight: .medium), lineHeight: 20)
            .foregroundColor(.secondary)
    }

    private var blurbText: some View {
        Text(bio.blurb)
            .fixedSize(horizontal: false, vertical: true)
            .foregroundColor(.primary)
            .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .medium), lineHeight: 22)
    }

    private var footer: some View {
        HStack(spacing: 4) {
            Text("Read their poems")
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
        }
        .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .medium), lineHeight: 24)
        .foregroundColor(colorScheme == .light ? .lightThemeColor : .darkThemeColor)
        .padding(.top, 4)
    }

    private var cardBackgroundColor: Color {
        colorScheme == .light ? .white : .black
    }
}
