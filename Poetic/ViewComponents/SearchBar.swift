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
            UIApplication.shared.windows.first { $0.isKeyWindow }?.endEditing(true)
        }
        
//        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//            searchTerm = searchText
//        }

    }


}
