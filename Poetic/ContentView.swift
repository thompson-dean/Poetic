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

struct ContentView: View {
    /// One service instance for the whole app — the 15MB catalog decodes once.
    private static let poemService = LocalPoemService()

    @StateObject var viewModel = PoemViewModel(service: ContentView.poemService)
    @ObservedObject var storeKitManager: StoreKitManager
    @EnvironmentObject var store: PoemStore

    @State private var selectedTab: AppTab = .home
    @State private var homePath = NavigationPath()
    @State private var deepLinkFailed = false
    @State private var showSettings = false
    @State private var showWidgetAnnouncement = false
    @AppStorage(Constants.hasSeenWidgetAnnouncement) private var hasSeenWidgetAnnouncement = false

    let notificationManager = NotificationManager()
    var authors: Authors = Bundle.main.decode("Authors.json")

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(viewModel: viewModel, path: $homePath, showSettings: $showSettings)
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
                showSettings: $showSettings
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
        .onChange(of: showSettings) { _, isShowing in
            if isShowing {
                AnalyticsEvents.settingsOpened()
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(
                viewModel: viewModel,
                storeKitManager: storeKitManager
            )
        }
        .sheet(isPresented: $showWidgetAnnouncement) {
            hasSeenWidgetAnnouncement = true
        } content: {
            WidgetAnnouncementView {
                // Give the announcement sheet a beat to finish dismissing
                // before presenting settings, or the second sheet is dropped.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showSettings = true
                }
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
            viewModel.pickFeaturedAuthors(
                from: authors.authors,
                poetOfTheDay: DailyPoetPicker.poet(for: Date(), in: PoetBios.all)?.author
            )

            Task {
                await WidgetDataRefresher(service: Self.poemService).refreshDailyIfNeeded()
            }

            if !hasSeenWidgetAnnouncement {
                // Slight delay so the sheet animates in over settled content
                // rather than fighting the launch transition.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    showWidgetAnnouncement = true
                }
            }
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
            showSettings = true
        case .poem(let title, let author):
            AnalyticsEvents.deepLinkOpened(type: "poem")
            Task {
                if let poem = await resolvePoem(title: title, author: author) {
                    selectedTab = .home
                    homePath = NavigationPath()
                    homePath.append(poem)
                } else {
                    deepLinkFailed = true
                }
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
