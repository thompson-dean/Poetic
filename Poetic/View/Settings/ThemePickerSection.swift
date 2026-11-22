//
//  ThemePickerSection.swift
//  Poetic
//
//  Created by Dean Thompson on 2026/11/22.
//

import SwiftUI

/// Settings row of theme swatches. Locked themes explain the tip unlock and
/// offer to scroll back up to the tip jar.
struct ThemePickerSection: View {
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject private var themeController: ThemeController
    @ObservedObject var storeKitManager: StoreKitManager
    let scrollToTips: () -> Void

    @State private var lockedThemeTapped: AppTheme?

    var body: some View {
        Section {
            // A grid rather than a horizontal scroll, so all six themes are
            // visible at once.
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 14) {
                ForEach(AppTheme.allCases) { option in
                    themeSwatch(option)
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("Theme")
        } footer: {
            if !storeKitManager.isSupporter {
                Text("Paper is free. Every other theme is unlocked by any tip – they apply to your widgets too.")
            }
        }
        .alert(
            "\(lockedThemeTapped?.displayName ?? "This theme") is a thank-you for supporters",
            isPresented: Binding(
                get: { lockedThemeTapped != nil },
                set: { if !$0 { lockedThemeTapped = nil } }
            )
        ) {
            Button("See tips", action: scrollToTips)
            Button("Not now", role: .cancel) {}
        } message: {
            Text("Any tip unlocks every theme, plus the Favorites widget.")
        }
    }

    private func themeSwatch(_ option: AppTheme) -> some View {
        let isLocked = !option.isFree && !storeKitManager.isSupporter
        let isSelected = option == themeController.effectiveTheme(isSupporter: storeKitManager.isSupporter)
        return Button {
            if isLocked {
                lockedThemeTapped = option
            } else {
                themeController.select(option)
                HapticFeedbackGenerator.shared.simpleHapticSuccess()
            }
        } label: {
            VStack(spacing: 6) {
                ZStack(alignment: .topTrailing) {
                    themePreview(option)
                        .environment(\.appTheme, option)
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.secondary)
                            .padding(6)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 88)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(
                            isSelected ? option.accent(for: colorScheme) : Color.secondary.opacity(0.25),
                            lineWidth: isSelected ? 2.5 : 1
                        )
                )

                Text(option.displayName)
                    .font(.caption.weight(isSelected ? .bold : .regular))
                    .foregroundStyle(.primary)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(option.displayName) theme\(isLocked ? ", locked" : "")")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    /// A miniature reading screen: background, accent bar and "Aa" in the
    /// theme's typeface.
    private func themePreview(_ option: AppTheme) -> some View {
        ZStack {
            ThemeBackgroundView()
            VStack(alignment: .leading, spacing: 4) {
                Text("Aa")
                    .font(Font(option.titleFont(size: 22)))
                    .foregroundStyle(.primary)
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(option.accent(for: colorScheme))
                        .frame(width: 2, height: 22)
                    VStack(alignment: .leading, spacing: 3) {
                        Capsule().fill(Color.primary.opacity(0.5)).frame(width: 34, height: 3)
                        Capsule().fill(Color.primary.opacity(0.5)).frame(width: 26, height: 3)
                        Capsule().fill(Color.primary.opacity(0.5)).frame(width: 30, height: 3)
                    }
                }
            }
        }
    }
}
