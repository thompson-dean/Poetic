//
//  ContentView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = PoemViewModel(apiService: APIService())
    @StateObject var pcViewModel = PersistenceController()
    @ObservedObject var storeKitManager: StoreKitManager
    
    let notificationManager = NotificationManager()
    
    var authors: Authors = Bundle.main.decode("Authors.json")
    
    var body: some View {
        TabView {
            NewHomeView(viewModel: viewModel, pcViewModel: pcViewModel)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            IntegratedSearchView(viewModel: viewModel, pcViewModel: pcViewModel)
                .tabItem {
                    Label("Explore", systemImage: "magnifyingglass")
                }
            FavoritesView(viewModel: viewModel, pcViewModel: pcViewModel)
                .tabItem {
                    Label("Favorites", systemImage: "star")
                }
            QuoteView(viewModel: viewModel, pcViewModel: pcViewModel)
                .tabItem {
                    Label("Quotes", systemImage: "quote.bubble.fill")
                }
            SettingsView(viewModel: viewModel, pcViewModel: pcViewModel, storeKitManager: storeKitManager)
                .tabItem {
                    Label("Menu", systemImage: "line.3.horizontal")
                }
        }
        .accentColor(.primary)
        .onAppear {
            notificationManager.requestAuthorization()
            SystemThemeManager.shared.handleTheme(darkMode: viewModel.darkModeEnabled, system: viewModel.systemThemeEnabled)
            UIApplication.shared.applicationIconBadgeNumber = 0
            viewModel.loadRandomPoems(number: "5")
            viewModel.featuredAuthor1 = authors.authors.randomElement() ?? ""
            viewModel.featuredAuthor2 = authors.authors.randomElement() ?? ""
            viewModel.featuredAuthor3 = authors.authors.randomElement() ?? ""
        }
        
    }
}
