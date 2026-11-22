//
//  TipRow.swift
//  Poetic
//
//  Created by Dean Thompson on 2026/11/22.
//

import StoreKit
import SwiftUI

/// One tip in the Settings tip jar. The featured (largest) tip is listed
/// first with a tinted card, a label and the only filled button, so the eye
/// lands there first.
struct TipRow: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.appTheme) private var theme
    let tip: Product
    let isFeatured: Bool
    let purchase: () -> Void

    private var themeColor: Color {
        theme.accent(for: colorScheme)
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(emoji)
                .font(.title3)
                .frame(width: 40, height: 40)
                .background(
                    themeColor.opacity(isFeatured ? 0.3 : 0.15),
                    in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                )

            VStack(alignment: .leading, spacing: 2) {
                if isFeatured {
                    Text("BIGGEST THANK-YOU")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1)
                        .foregroundStyle(themeColor)
                }
                Text(tipName)
                    .font(.body.weight(.semibold))
                if !tipDescription.isEmpty {
                    Text(tipDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
            }

            Spacer()

            priceButton
        }
        .padding(.vertical, isFeatured ? 8 : 4)
        .listRowBackground(rowBackground)
    }

    @ViewBuilder
    private var priceButton: some View {
        let button = Button(tip.displayPrice, action: purchase)
            .tint(themeColor)
            .font(.callout.bold())

        if isFeatured {
            button.buttonStyle(.borderedProminent)
        } else {
            button.buttonStyle(.bordered)
        }
    }

    @ViewBuilder
    private var rowBackground: some View {
        if isFeatured {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(themeColor.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(themeColor.opacity(0.6), lineWidth: 1.5)
                )
        } else {
            Color(.secondarySystemGroupedBackground)
        }
    }

    /// The app's own names, so the tip jar reads right regardless of what
    /// App Store Connect has (it said "Large Tip" etc.). Unknown products
    /// fall back to the store's name.
    private var tipName: String {
        if tip.id.hasSuffix("smallTip") { return "Chocolate" }
        if tip.id.hasSuffix("mediumTip") { return "Coffee" }
        if tip.id.hasSuffix("largeTip") { return "Coffee & Chocolate" }
        return tip.displayName
    }

    /// The app's own one-line descriptions, matching `tipName`. Unknown
    /// products fall back to the store's description.
    private var tipDescription: String {
        if tip.id.hasSuffix("smallTip") { return "A sweet little thank-you" }
        if tip.id.hasSuffix("mediumTip") { return "Coffee for the next poem" }
        if tip.id.hasSuffix("largeTip") { return "Fuel for new features" }
        return tip.description.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var emoji: String {
        if tip.id.hasSuffix("smallTip") { return "🍫" }
        if tip.id.hasSuffix("mediumTip") { return "☕️" }
        return "✨"
    }
}

/// Shown instead of an endless spinner when the tips couldn't be loaded.
struct TipsUnavailableRow: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.appTheme) private var theme
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            Text("Couldn't load tips right now.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Try again", action: retry)
                .font(.subheadline.weight(.semibold))
                .tint(theme.accent(for: colorScheme))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}
