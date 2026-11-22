//
//  ContentView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import SwiftUI

enum AppTab: Hashable {
    case home, explore, favorites, quotes
}

/// Every way into Settings, which opens on the tip jar. Logged as `source`
/// on settings_opened and supporter_screen_viewed.
enum SettingsSource: String, Identifiable {
    case home
    case favoritesNudge = "favorites_nudge"
    case widgetPromo = "widget_promo"
    case lockedWidget = "locked_widget"

    var id: String { rawValue }
}

/// A poem pushed onto the Home stack programmatically, tagged with the
/// analytics source that DetailView reports.
struct PoemRoute: Hashable {
    let poem: Poem
    let source: String
}

struct ContentView: View {
    /// One service instance for the whole app — the 15MB catalog decodes once.
    private static let poemService = LocalPoemService()

    @StateObject var viewModel = PoemViewModel(service: ContentView.poemService)
    @ObservedObject var storeKitManager: StoreKitManager
    @EnvironmentObject var store: PoemStore

    @State private var selectedTab: AppTab = .home
    @State private var homePath = NavigationPath()
    @State private var deepLinkFailed = false
    @State private var settingsSource: SettingsSource?
    @State private var showWidgetAnnouncement = false
    @State private var didHandleLaunch = false
    /// New installs see the widget announcement after their first poem.
    @State private var showPromoAfterFirstPoem = false
    @AppStorage(Constants.hasSeenWidgetAnnouncement) private var hasSeenWidgetAnnouncement = false
    @AppStorage(Constants.lastSeenAnnouncementVersion) private var lastSeenAnnouncement = ""

    /// Bump when the "New in Poetic" sheet has new content worth showing to
    /// people who saw the previous one.
    static let currentAnnouncement = "3.1"

    private var needsAnnouncement: Bool {
        lastSeenAnnouncement != Self.currentAnnouncement
    }
    @AppStorage(Constants.hasCompletedFirstLaunch) private var hasCompletedFirstLaunch = false

    let notificationManager = NotificationManager()
    var authors: Authors = Bundle.main.decode("Authors.json")

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(viewModel: viewModel, path: $homePath, settingsSource: $settingsSource)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(AppTab.home)
            IntegratedSearchView(viewModel: viewModel)
                .tabItem {
                    Label("Explore", systemImage: "magnifyingglass")
                }
                .tag(AppTab.explore)
            FavoritesView(
                viewModel: viewModel,
                storeKitManager: storeKitManager,
                settingsSource: $settingsSource
            )
                .tabItem {
                    Label("Favorites", systemImage: "star")
                }
                .tag(AppTab.favorites)
            QuoteView(viewModel: viewModel)
                .tabItem {
                    Label("Quotes", systemImage: "quote.bubble.fill")
                }
                .tag(AppTab.quotes)
        }
        .accentColor(.primary)
        .onChange(of: selectedTab) { _, newTab in
            AnalyticsEvents.tabSelected(String(describing: newTab))
        }
        .onChange(of: settingsSource) { _, source in
            if let source {
                AnalyticsEvents.settingsOpened(source: source.rawValue)
            }
        }
        .sheet(item: $settingsSource) { source in
            SettingsView(
                viewModel: viewModel,
                storeKitManager: storeKitManager,
                source: source
            )
        }
        .sheet(isPresented: $showWidgetAnnouncement) {
            hasSeenWidgetAnnouncement = true
            lastSeenAnnouncement = Self.currentAnnouncement
        } content: {
            WhatsNewView(isSupporter: storeKitManager.isSupporter) {
                // Give the announcement sheet a beat to finish dismissing
                // before presenting settings, or the second sheet is dropped.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    settingsSource = .widgetPromo
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .poemDidClose)) { _ in
            guard showPromoAfterFirstPoem, needsAnnouncement else { return }
            showPromoAfterFirstPoem = false
            // Let the pop animation finish before the sheet slides up.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                showWidgetAnnouncement = true
            }
        }
        .onOpenURL { url in
            handle(url)
        }
        .alert("Poem not found", isPresented: $deepLinkFailed) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("That poem isn't in the current library.")
        }
        .onAppear {
            notificationManager.requestAuthorization()
            SystemThemeManager.shared.handleTheme(
                darkMode: viewModel.darkModeEnabled,
                system: viewModel.systemThemeEnabled
            )

            viewModel.resetBadgeCount()
            viewModel.loadRandomPoems(number: "5")
            viewModel.loadDiscoverPoems(number: "5")
            viewModel.loadTodaysPoem()
            viewModel.pickFeaturedAuthors(
                from: authors.authors,
                poetOfTheDay: DailyPoetPicker.poet(for: Date(), in: PoetBios.all)?.author
            )

            Task {
                await WidgetDataRefresher(service: Self.poemService).refreshDailyIfNeeded()
            }

            handleLaunch()
        }
    }

    private func handle(_ url: URL) {
        guard let link = DeepLink(url: url) else { return }
        switch link {
        case .home:
            AnalyticsEvents.deepLinkOpened(type: "home")
            selectedTab = .home
        case .favorites:
            AnalyticsEvents.deepLinkOpened(type: "favorites")
            selectedTab = .favorites
        case .support:
            AnalyticsEvents.deepLinkOpened(type: "support")
            selectedTab = .home
            settingsSource = .lockedWidget
        case .poem(let title, let author):
            AnalyticsEvents.deepLinkOpened(type: "poem")
            Task {
                if let poem = await resolvePoem(title: title, author: author) {
                    selectedTab = .home
                    homePath = NavigationPath()
                    homePath.append(PoemRoute(poem: poem, source: "deep_link"))
                } else {
                    deepLinkFailed = true
                }
            }
        }
    }

    /// On a brand-new install the first thing people see is Home with
    /// Today's Poem on top, not a sales sheet: the widget announcement waits
    /// until they come back from their first poem (or their next launch, if
    /// they don't read one). Users upgrading from an older build have
    /// already seen the announcement, so they're never treated as new.
    private func handleLaunch() {
        guard !didHandleLaunch else { return }
        didHandleLaunch = true

        let isNewInstall = !hasCompletedFirstLaunch && !hasSeenWidgetAnnouncement
        hasCompletedFirstLaunch = true

        if isNewInstall {
            showPromoAfterFirstPoem = true
        } else if needsAnnouncement {
            // Slight delay so the sheet animates in over settled content
            // rather than fighting the launch transition.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                showWidgetAnnouncement = true
            }
        }
    }

    /// Catalog first; favorites fall back so a favorited poem still opens
    /// even if a catalog update changed its text or removed it.
    private func resolvePoem(title: String, author: String) async -> Poem? {
        if let poem = try? await Self.poemService.poem(titled: title, by: author) {
            return poem
        }
        return store.favorites
            .first { $0.title == title && $0.author == author }?
            .asPoem()
    }
}
