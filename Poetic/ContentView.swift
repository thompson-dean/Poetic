//
//  ContentView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import SwiftUI

struct ContentView: View {
    
    
    @State private var tabSelection = 1
    @State private var tappedTwice: Bool = false
    
    @State private var home = UUID()
    @State private var search = UUID()
    @State private var favorites = UUID()
    @State private var quotes = UUID()
    @State private var menu = UUID()
    
    
    @StateObject var viewModel = SearchViewModel()
    @StateObject var pcViewModel = PersistenceController()
    
    
    var body: some View {
        var handler: Binding<Int> { Binding(
            get: { self.tabSelection },
            set: {
                if $0 == self.tabSelection {
                    tappedTwice = true
                }
                self.tabSelection = $0
            }
        )}
        
        
        return TabView(selection: handler) {
            HomeView(viewModel: viewModel, pcViewModel: pcViewModel)
                .tabItem {
                    Label("Home", systemImage: "house")
                        .onChange(of: tappedTwice) { tappedTwice in
                            guard tappedTwice else { return }
                            home = UUID()
                            self.tappedTwice = false
                        }
                }.tag(1)
                
            SearchView(viewModel: viewModel, pcViewModel: pcViewModel)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                        .onChange(of: tappedTwice) { tappedTwice in
                            guard tappedTwice else { return }
                            home = UUID()
                            self.tappedTwice = false
                        }
                }.tag(2)
               
                
            FavoritesView(viewModel: viewModel, pcViewModel: pcViewModel)
                .tabItem {
                    Label("Favorites", systemImage: "star")
                }
            
            QuoteView(viewModel: viewModel, pcViewModel: pcViewModel)
                .tabItem {
                    Label("Quotes", systemImage: "quote.bubble.fill")
                }
            SettingsView(viewModel: viewModel)
                .tabItem {
                    Label("Menu", systemImage: "line.3.horizontal")
                }
        }
        .accentColor(.primary)
        .onAppear {
            SystemThemeManager.shared.handleTheme(darkMode: viewModel.darkModeEnabled, system: viewModel.systemThemeEnabled)
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

