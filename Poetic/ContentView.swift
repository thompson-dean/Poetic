//
//  ContentView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import SwiftUI



struct ContentView: View {
    @StateObject var viewModel = SearchViewModel()
    
    
    
    var body: some View {
        TabView {
            HomeView(viewModel: viewModel)
                .tabItem {
                    Label("Home", systemImage: "house")
                        
                }
                
            SearchView(viewModel: viewModel)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                        
                }
               
                
            FavoritesView(viewModel: viewModel)
                .tabItem {
                    Label("Favorites", systemImage: "star")
                        
                }
                
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                        
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

