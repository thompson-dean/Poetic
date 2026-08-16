//
//  SettingsView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/21.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var notificationManager = NotificationManager()
    @ObservedObject var viewModel: PoemViewModel
    @ObservedObject var storeKitManager: StoreKitManager

    @State private var showLoading: Bool = false
    @State private var showThankYou: Bool = false
    @State var showPendingAlert: Bool = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                Form {
                    supportSection
                    appearanceSection
                    notificationsSection
                    resourcesSection
                    linksSection
                    versionSection
                }
                .overlay(alignment: .bottom) {
                    if showThankYou {
                        thankYouView
                    }
                }
                .animation(.spring(), value: showThankYou)
            }
            .onChange(of: storeKitManager.paymentState) { state, _ in
                if state == .successful {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        self.showThankYou = true
                        storeKitManager.reset()
                    }
                }

                if state == .pending {
                    showPendingAlert = true
                }
            }
            // swiftlint:disable line_length
            .alert(isPresented: $showPendingAlert) {
                Alert(
                    title: Text("Your payment is pending."),
                    message: Text("This may be due to a poor connection or suddenly closing the app. You will be notified when your payment has been successful."),
                    dismissButton: .default(Text("OK"))
                )
            }
            // swiftlint:enable line_length
            .alert(isPresented: $storeKitManager.hasError, error: storeKitManager.error) { }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private extension SettingsView {
    var themeColor: Color {
        colorScheme == .light ? .lightThemeColor : .darkThemeColor
    }

    var supportSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 6) {
                Label {
                    Text("Support Poetic")
                        .font(.system(.title3, design: .serif).bold())
                } icon: {
                    Image(systemName: "heart.fill")
                        .foregroundColor(themeColor)
                }

                // swiftlint:disable:next line_length
                Text("All the poetry in Poetic is free — and it always will be. Any tip, big or small, unlocks the Favorites home screen widget as a thank you.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)

            if storeKitManager.isSupporter {
                Label("Widget unlocked — thank you!", systemImage: "checkmark.seal.fill")
                    .font(.callout.bold())
                    .foregroundStyle(.green)
            }

            if storeKitManager.tips.isEmpty {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            } else {
                ForEach(storeKitManager.tips) { tip in
                    tipRow(for: tip)
                }
            }

            HStack {
                Spacer()
                Button("Restore Purchases") {
                    Task {
                        await storeKitManager.restorePurchases()
                    }
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                Spacer()
            }
        } footer: {
            Text("Tips are one-time purchases — no subscriptions, ever.")
        }
    }

    func tipRow(for tip: Product) -> some View {
        HStack(spacing: 12) {
            Text(tipEmoji(for: tip))
                .font(.title3)
                .frame(width: 40, height: 40)
                .background(
                    themeColor.opacity(0.15),
                    in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(tip.displayName)
                    .font(.body.weight(.semibold))
                Text(tip.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button(tip.displayPrice) {
                Task {
                    await storeKitManager.purchase(tip)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(themeColor)
            .font(.callout.bold())
        }
        .padding(.vertical, 4)
    }

    func tipEmoji(for tip: Product) -> String {
        if tip.id.hasSuffix("smallTip") { return "🍫" }
        if tip.id.hasSuffix("mediumTip") { return "☕️" }
        return "✨"
    }

    var thankYouView: some View {
        VStack(spacing: 8) {
            Text("Thank you for your support!")
                .font(.system(.title2).bold())
                .multilineTextAlignment(.center)

            Text("Thank you for supporting Poetic! Here's to more inspiring verses and enriched experiences, together!")
                .font(.system(.body, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.bottom, 16)

            Button {
                showThankYou.toggle()
            } label: {
                Text("Close")
                    .font(.system(.title3).bold())
                    .tint(colorScheme == .light ? .white : .black)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(
                        colorScheme == .light ? Color.lightThemeColor : Color.darkThemeColor,
                        in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                    )
            }
        }
        .padding(16)
        .background(
            colorScheme == .light ? .white : Color(0x181716),
            in: RoundedRectangle(cornerRadius: 10, style: .continuous)
        )
        .padding(.horizontal, 8)
        .padding(.bottom, 8)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    var appearanceSection: some View {
        Section(header: Text("Appearance")) {
            Toggle("Adaptive background", isOn: $viewModel.systemThemeEnabled)
                .onChange(of: viewModel.systemThemeEnabled) { _, _ in
                    SystemThemeManager.shared.handleTheme(
                        darkMode: viewModel.darkModeEnabled,
                        system: viewModel.systemThemeEnabled
                    )
                }

            if !viewModel.systemThemeEnabled {
                Picker("", selection: $viewModel.darkModeEnabled) {
                    Text("Light").tag(false)
                    Text("Dark").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: viewModel.darkModeEnabled) { _, _ in
                    SystemThemeManager.shared.handleTheme(
                        darkMode: viewModel.darkModeEnabled,
                        system: viewModel.systemThemeEnabled
                    )
                }
            }
        }
    }

    var notificationsSection: some View {
        Section(header: Text("Notifications")) {
            Toggle("Notifications On", isOn: $notificationManager.notificationOn)
                .onChange(of: notificationManager.notificationOn) { _, _ in
                    if notificationManager.notificationOn {
                        notificationManager.addNotification()
                    } else {
                        notificationManager.deleteNotification()
                    }
                }
        }
    }

    var resourcesSection: some View {
        Section(header: Text("Resources")) {
            NavigationLink {
                if let url = URL(string: Links.poetryDBURLSTring) {
                    WebView(url: url, showLoading: $showLoading)
                        .overlay(
                            showLoading ? ProgressView("Loading...").toAnyView() : EmptyView().toAnyView()
                        )
                }
            } label: {
                Text("PoetryDB's fantastic poetry API")
            }
            NavigationLink {
                if let url = URL(string: Links.poeticURLString) {
                    WebView(url: url, showLoading: $showLoading)
                        .overlay(
                            showLoading ? ProgressView("Loading...").toAnyView() : EmptyView().toAnyView()
                        )
                }
            } label: {
                Text("Poetic open source repository")
            }
        }
    }

    var linksSection: some View {
        Section {
            Button("FIREBASE TEST CRASH") { fatalError("TEST CRASH")}
            Button {
                if let url = URL(string: Links.appStoreDeepLink) {
                            UIApplication.shared.open(url)
                        } else {
                            print("error with app store URL")
                        }
            } label: {
                ZStack {
                    NavigationLink(destination: EmptyView()) {

                    }
                    HStack {
                        Image(systemName: "hand.thumbsup")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .padding(.trailing)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Leave a rating")

                            Text("Support this app, support poetry!")
                                .font(.caption)
                        }
                        Spacer()
                    }
                    .foregroundColor(.primary)
                }
            }
            Button {
                Links.shareApp()
            } label: {
                ZStack {
                    NavigationLink(destination: EmptyView()) {

                    }
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .padding(.trailing)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Share")

                            Text("Send to your friend's who love poetry.")
                                .font(.caption)
                        }
                        Spacer()
                    }
                    .foregroundColor(.primary)
                }

            }

            NavigationLink {
                if let url = URL(string: Links.twitterPoeticURLString) {
                    WebView(url: url, showLoading: $showLoading)
                        .overlay(
                            showLoading ?
                            ProgressView("Loading...") .toAnyView() :
                            EmptyView().toAnyView()
                        )
                } else {

                }
            } label: {
                HStack {
                    Image(systemName: "envelope")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .padding(.trailing)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Send feedback")

                        Text("Want new features? Found a bug?")
                            .font(.caption)
                    }
                }
            }
            NavigationLink {
                DevView()
            } label: {
                HStack {
                    Image(systemName: "info.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .padding(.trailing)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("About the app")

                        Text("App and developer information")
                            .font(.caption)
                    }
                }
            }
        }
    }

    var versionSection: some View {
        Section {
            NavigationLink {
                if let url = URL(string: Links.twitterURLString) {
                    WebView(url: url, showLoading: $showLoading)
                        .overlay(
                            showLoading ?
                            ProgressView("Loading...").toAnyView() :
                            EmptyView().toAnyView()
                        )
                } else {

                }
            } label: {
                HStack {
                    Image("poeticPic")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .cornerRadius(5)

                    VStack(alignment: .leading, spacing: 5) {
                        Text("Poetic version \(Bundle.main.appVersion)")
                        HStack(spacing: 3) {
                            Text("Made with love by")

                            Text("@DeanWThompson")
                                .foregroundColor(.blue)
                        }
                        .font(.caption)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}
