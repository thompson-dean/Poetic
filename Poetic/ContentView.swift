//
//  ContentView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var viewModel = SearchViewModel()
    @StateObject var pcViewModel = PersistenceController()
    
    
    var body: some View {
        TabView {
            HomeView(viewModel: viewModel, pcViewModel: pcViewModel)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                
            SearchView(viewModel: viewModel, pcViewModel: pcViewModel)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
               
                
            FavoritesView(viewModel: viewModel, pcViewModel: pcViewModel)
                .tabItem {
                    Label("Favorites", systemImage: "star")
                }
            
            QuoteView(viewModel: viewModel, pcViewModel: pcViewModel)
                .tabItem {
                    Label("Quotes", systemImage: "quote.bubble.fill")
                }
        }
        .accentColor(.black)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

