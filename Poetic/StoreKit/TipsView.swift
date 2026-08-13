//
//  TipsView.swift
//  Poetic
//
//  Created by Dean Thompson on 2023/07/20.
//

import SwiftUI
import StoreKit

struct TipsView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var storeKitManager: StoreKitManager
    @Binding var isShowingTipsView: Bool

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Spacer()
                Button {
                    isShowingTipsView.toggle()
                } label: {
                    Image(systemName: "xmark")
                        .symbolVariant(.circle.fill)
                        .font(.system(.largeTitle, design: .rounded).bold())
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.gray, .gray.opacity(0.2))
                }
            }

            Text("Support Poetic")
                .font(.system(.title2).bold())
                .multilineTextAlignment(.center)

            // swiftlint:disable line_length
            Text("All the poetry in Poetic is free — and it always will be. Becoming a supporter unlocks the Favorites home screen widget (and future little extras) as a thank you.")
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)
            // swiftlint:enable line_length

            if let supporter = storeKitManager.supporterProduct {
                SupporterItemView(
                    item: supporter,
                    isUnlocked: storeKitManager.isSupporter
                ) {
                    Task {
                        await storeKitManager.purchase(supporter)
                    }
                }
            }

            Text("Just want to leave a tip? These don't unlock anything — they're pure kindness.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.top, 8)

            ForEach(storeKitManager.tips) { item in
                TipsItemView(item: item) {
                    Task {
                        await storeKitManager.purchase(item)
                    }
                }
            }

            Button("Restore Purchases") {
                Task {
                    await storeKitManager.restorePurchases()
                }
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.top, 4)
        }
        .padding(16)
        .background(
            colorScheme == .light ? .white.opacity(0.9) : Color(0x181716),
            in: RoundedRectangle(cornerRadius: 10, style: .continuous)
        )
        .padding(8)
        .overlay(alignment: .top) {
            Image("poeticPic")
                .resizable()
                .scaledToFit()
                .cornerRadius(8)
                .frame(width: 50, height: 50)
                .padding(6)
                .offset(y: -25)
        }
    }
}

struct SupporterItemView: View {
    @Environment(\.colorScheme) var colorScheme
    let item: Product
    let isUnlocked: Bool
    let purchaseButtonTapped: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(item.displayName)
                    .font(.system(.title3, design: .rounded).bold())
                Text(item.description)
                    .font(.system(.callout, design: .rounded).weight(.regular))
            }

            Spacer()

            if isUnlocked {
                Label("Unlocked", systemImage: "checkmark.seal.fill")
                    .font(.callout.bold())
                    .foregroundStyle(.green)
            } else {
                Button(item.displayPrice) {
                    purchaseButtonTapped()
                }
                .tint(colorScheme == .light ? Color.lightThemeColor : Color.darkThemeColor)
                .buttonStyle(.borderedProminent)
                .font(.callout.bold())
            }
        }
        .padding(16)
        .background(
            Color(UIColor.systemBackground),
            in: RoundedRectangle(cornerRadius: 10, style: .continuous)
        )
    }
}

struct TipsItemView: View {
    @Environment(\.colorScheme) var colorScheme
    let item: Product
    let purchaseButtonTapped: () -> Void
    var body: some View {
        HStack {
            VStack(alignment: .leading,
                   spacing: 3) {
                Text(item.displayName)
                    .font(.system(.title3, design: .rounded).bold())
                Text(item.description)
                    .font(.system(.callout, design: .rounded).weight(.regular))
            }

            Spacer()

            Button(item.displayPrice) {
              purchaseButtonTapped()
            }
            .tint(colorScheme == .light ? Color.lightThemeColor : Color.darkThemeColor)
            .buttonStyle(.bordered)
            .font(.callout.bold())
        }
        .padding(16)
        .background(
            Color(UIColor.systemBackground),
            in: RoundedRectangle(cornerRadius: 10, style: .continuous)
        )
    }
}
