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
    let notificationManager = NotificationManager()
    
    var body: some View {
        var handler: Binding<Int> { Binding(
            get: { self.tabSelection },
            set: {
                if $0 == self.tabSelection {
                    withAnimation {
                        tappedTwice = true
                    }
                    
                }
                self.tabSelection = $0
            }
        )}
        
        
        return TabView(selection: handler) {
            HomeView(viewModel: viewModel, pcViewModel: pcViewModel)
                .id(home)
                .tabItem {
                    //Add a different SFSymbol
                    Label("Explore", systemImage: "house")
                        .onChange(of: tappedTwice) { tappedTwice in
                            guard tappedTwice else { return }
                            home = UUID()
                            self.tappedTwice = false
                        }
                }
                .tag(1)
                
            SearchView(viewModel: viewModel, pcViewModel: pcViewModel)
                .id(search)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                        .onChange(of: tappedTwice) { tappedTwice in
                            guard tappedTwice else { return }
                            search = UUID()
                            self.tappedTwice = false
                        }
                }
                .tag(2)
               
                
            FavoritesView(viewModel: viewModel, pcViewModel: pcViewModel)
                .id(favorites)
                .tabItem {
                    Label("Favorites", systemImage: "star")
                        .onChange(of: tappedTwice) { tappedTwice in
                            guard tappedTwice else { return }
                            favorites = UUID()
                            self.tappedTwice = false
                        }
                }
                .tag(3)
            
            QuoteView(viewModel: viewModel, pcViewModel: pcViewModel)
                .id(quotes)
                .tabItem {
                    Label("Quotes", systemImage: "quote.bubble.fill")
                        .onChange(of: tappedTwice) { tappedTwice in
                            guard tappedTwice else { return }
                            quotes = UUID()
                            self.tappedTwice = false
                        }
                }
                .tag(4)
            
            SettingsView(viewModel: viewModel)
                .id(menu)
                .tabItem {
                    if #available(iOS 15.0, *) {
                        Label("Menu", systemImage: "line.3.horizontal")
                            .onChange(of: tappedTwice) { tappedTwice in
                                    guard tappedTwice else { return }
                                    menu = UUID()
                                    self.tappedTwice = false
                                }
                    } else {
                        Label("Menu", systemImage: "gear")
                            .onChange(of: tappedTwice) { tappedTwice in
                                    guard tappedTwice else { return }
                                    menu = UUID()
                                    self.tappedTwice = false
                                }
                    }
                    
                }
                .tag(5)
        }
        .accentColor(.primary)
        .onAppear {
            notificationManager.requestAuthorization()
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

