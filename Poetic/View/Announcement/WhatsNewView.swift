//
//  WhatsNewView.swift
//  Poetic
//
//  Created by Dean Thompson on 2026/08/16.
//

import SwiftUI

/// "New in Poetic" sheet, shown once per announcement version (see
/// `ContentView.currentAnnouncement`): on launch for people updating, after
/// their first poem for new installs. Dismissal is recorded by the caller.
struct WhatsNewView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.appTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    let isSupporter: Bool
    /// Called when the user taps the main button — the caller opens Settings
    /// (tips and the theme picker) after this sheet closes.
    let openSettings: () -> Void

    private var accent: Color {
        theme.accent(for: colorScheme)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("New in Poetic")
                .font(.system(.title, design: .serif).bold())
                .padding(.top, 32)

            HStack(spacing: 16) {
                mockWidget(
                    in: .sepia,
                    eyebrow: "POEM OF THE DAY",
                    lines: ["I wandered lonely", "as a cloud..."],
                    footer: "William Wordsworth",
                    locked: false
                )
                mockWidget(
                    in: .midnight,
                    eyebrow: "FROM YOUR FAVORITES",
                    lines: ["Shall I compare thee", "to a summer's day?"],
                    footer: "William Shakespeare",
                    locked: !isSupporter
                )
            }

            VStack(alignment: .leading, spacing: 12) {
                row(
                    symbol: "paintpalette.fill",
                    text: "Six reading themes – Sepia, Sage, Midnight, Rose and more. "
                        + "Your widgets match your theme."
                )
                row(
                    symbol: "sparkles",
                    text: "Today's Poem on Home, and a free Poem of the Day widget. "
                        + "Large widgets now show the whole poem."
                )
                row(
                    symbol: "star.fill",
                    text: isSupporter
                        ? "Your Favorites widget rotates through your own anthology – now in large too."
                        : "Any tip unlocks every theme and the Favorites widget, "
                            + "which rotates through your own anthology."
                )
                row(
                    symbol: "plus.circle",
                    text: "To add a widget, press and hold your Home Screen, tap Edit, "
                        + "then Add Widget, and search for Poetic."
                )
            }
            .padding(.horizontal, 24)

            Spacer(minLength: 0)

            Button {
                AnalyticsEvents.widgetPromoAction(action: isSupporter ? "themes" : "support")
                dismiss()
                openSettings()
            } label: {
                Text(isSupporter ? "Choose a theme" : "Unlock themes & widgets")
                    .font(.system(.body).bold())
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            .buttonStyle(.borderedProminent)
            .tint(accent)
            .padding(.horizontal, 24)

            Button {
                AnalyticsEvents.widgetPromoAction(action: "dismiss")
                dismiss()
            } label: {
                Text(isSupporter ? "Close" : "Maybe later")
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 16)
        }
        .onAppear {
            AnalyticsEvents.widgetPromoShown()
        }
    }

    /// A miniature widget drawn in a given theme, to show that widgets
    /// follow the chosen theme.
    private func mockWidget(
        in mockTheme: AppTheme,
        eyebrow: String,
        lines: [String],
        footer: String,
        locked: Bool
    ) -> some View {
        let mockAccent = mockTheme.accent(for: colorScheme)
        return VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Text(eyebrow)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(mockAccent)
                    .lineLimit(1)
                if locked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 8))
                        .foregroundColor(mockAccent)
                }
            }

            ForEach(lines, id: \.self) { line in
                Text(line)
                    .font(mockTheme.widgetFont(size: 12))
                    .italic()
                    .lineLimit(1)
            }

            Spacer()

            Text(footer)
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding(12)
        .frame(width: 150, height: 150, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(mockTheme.backgroundColor(for: colorScheme) ?? mockTheme.card(for: colorScheme))
                .shadow(color: .black.opacity(0.25), radius: 10, y: 4)
        )
    }

    private func row(symbol: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(accent)
                .frame(width: 26)
            Text(text)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
