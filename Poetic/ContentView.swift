//
//  ContentView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = SearchViewModel()
    @State private var authorSearch = true
    var body: some View {
        NavigationView {
            
            
            Form {
                
                Section(header: Text("Search By...")) {
                    Picker("", selection: $authorSearch) {
                        Text("Author").tag(true)
                        Text("Title").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section {
                    HStack {
                        TextField("Search...", text: $viewModel.searchTerm)
                            
                        Button {
                            if authorSearch {
                                viewModel.loadPoem(searchterm: viewModel.searchTerm, filter: .author)
                            } else {
                                viewModel.loadPoem(searchterm: viewModel.searchTerm, filter: .title)
                            }
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.primary)
                        }
                    }
                }
                
                if viewModel.searchTerm.isEmpty {
                    VStack(alignment: .center) {
                        Text("Search for some poems!")
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.purple)
                            .frame(width: 200, height: 200)
                            .padding()
                    }
                    .frame(width: 300, height: 300)
                } else {
                    List(viewModel.poems) { poem in
                        NavigationLink {
                            DetailView(title: poem.title, author: poem.author, poemLines: poem.lines, linecount: poem.linecount)
                        } label: {
                            VStack(alignment: .leading) {
                                if authorSearch {
                                    Text(poem.author)
                                        .font(.headline)
                                    Text(poem.title)
                                        .font(.subheadline)
                                } else {
                                    Text(poem.title)
                                        .font(.headline)
                                    Text(poem.author)
                                        .font(.subheadline)
                                }
                            }
                            
                        }
                    }
                }
                
                
            }
            .onChange(of: viewModel.searchTerm) { _ in
                if authorSearch {
                    viewModel.loadPoem(searchterm: viewModel.searchTerm, filter: .author)
                } else {
                    viewModel.loadPoem(searchterm: viewModel.searchTerm, filter: .title)
                }
            }
            .navigationTitle("Search Poems")
        }
    }
}

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

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
