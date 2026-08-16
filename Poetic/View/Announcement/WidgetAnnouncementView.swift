//
//  WidgetAnnouncementView.swift
//  Poetic
//
//  Created by Dean Thompson on 2026/08/16.
//

import SwiftUI

/// One-time "widgets have arrived" sheet, shown on the first launch of a
/// build that ships widgets. Dismissal is recorded by the caller via the
/// `hasSeenWidgetAnnouncement` default.
struct WidgetAnnouncementView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) private var dismiss

    /// Set when the user chooses "unlock Favorites" — the caller opens the
    /// settings sheet after this one closes.
    let openSupport: () -> Void

    private var themeColor: Color {
        colorScheme == .light ? .lightThemeColor : .darkThemeColor
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Poetic, now on your\nHome Screen")
                .font(.system(.title, design: .serif).bold())
                .multilineTextAlignment(.center)
                .padding(.top, 32)

            HStack(spacing: 16) {
                mockWidget(
                    eyebrow: "POEM OF THE DAY",
                    lines: ["I wandered lonely", "as a cloud..."],
                    footer: "William Wordsworth",
                    locked: false
                )
                mockWidget(
                    eyebrow: "FROM YOUR FAVORITES",
                    lines: ["Shall I compare thee", "to a summer's day?"],
                    footer: "William Shakespeare",
                    locked: true
                )
            }

            VStack(alignment: .leading, spacing: 12) {
                announcementRow(
                    symbol: "sparkles",
                    text: "A hand-picked short poem on your Home Screen, new every morning. Free, always."
                )
                announcementRow(
                    symbol: "star.fill",
                    text: "The Favorites widget rotates through your own anthology — unlocked by any tip."
                )
                announcementRow(
                    symbol: "plus.circle",
                    text: "Press and hold your Home Screen, tap the ➕, and search for Poetic."
                )
            }
            .padding(.horizontal, 24)

            Spacer()

            Button {
                AnalyticsEvents.widgetPromoAction(action: "support")
                dismiss()
                openSupport()
            } label: {
                Text("Unlock the Favorites widget")
                    .font(.system(.body).bold())
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
            }
            .buttonStyle(.borderedProminent)
            .tint(themeColor)
            .padding(.horizontal, 24)

            Button {
                AnalyticsEvents.widgetPromoAction(action: "dismiss")
                dismiss()
            } label: {
                Text("Maybe later")
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 16)
        }
        .onAppear {
            AnalyticsEvents.widgetPromoShown()
        }
    }

    private func mockWidget(
        eyebrow: String,
        lines: [String],
        footer: String,
        locked: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Text(eyebrow)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(themeColor)
                    .lineLimit(1)
                if locked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 8))
                        .foregroundColor(themeColor)
                }
            }

            ForEach(lines, id: \.self) { line in
                Text(line)
                    .font(.system(size: 12, design: .serif).italic())
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
                .fill(colorScheme == .light ? Color.white : Color.black)
                .shadow(color: .black.opacity(0.25), radius: 10, y: 4)
        )
    }

    private func announcementRow(symbol: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(themeColor)
                .frame(width: 26)
            Text(text)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
