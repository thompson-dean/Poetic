//
//  SearchBar.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/09.
//

import SwiftUI


struct SearchBar: UIViewRepresentable {
    typealias UIViewType = UISearchBar

    @Binding var searchTerm: String


    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.searchBarStyle = .minimal
        //Repeat the context
        searchBar.placeholder = "Search..."
        return searchBar

    }
    func updateUIView(_ uiView: UISearchBar, context: Context) {
        uiView.text = searchTerm

    }

    func makeCoordinator() -> SearchBarCoordinator {

        return SearchBarCoordinator(searchTerm: $searchTerm)
    }

    class SearchBarCoordinator: NSObject, UISearchBarDelegate {
        @Binding var searchTerm: String

        init(searchTerm: Binding<String>) {
            self._searchTerm = searchTerm
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchTerm = searchBar.text ?? ""
            
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as! UIWindowScene
            windowScene.windows.first { $0.isKeyWindow }?.endEditing(true)
        }
        
        // Research how to implement dynamic search.
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            searchTerm = searchText
        }

    }


}
