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
            FavoritesView(viewModel: viewModel)
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
        .sheet(isPresented: $showSettings) {
            SettingsView(
                viewModel: viewModel,
                storeKitManager: storeKitManager
            )
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
        }
    }

    private func handle(_ url: URL) {
        guard let link = DeepLink(url: url) else { return }
        switch link {
        case .home:
            selectedTab = .home
        case .favorites:
            selectedTab = .favorites
        case .support:
            selectedTab = .home
            showSettings = true
        case .poem(let title, let author):
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
