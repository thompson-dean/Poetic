//
//  SearchViewModel.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import Foundation

class SearchViewModel: ObservableObject {
    
    // loading state for Home View and Author View
    enum State {
        case idle
        case loading
        case failed(Error)
        case loaded
    }
    
    //loading state for title search.
    enum SearchTitleState {
        case idle
        case loading
        case failed(Error)
        case loaded
    }
    
    
    let dataManager = DataManager()
    
    //Arrays
    @Published var quotes = [Quote]()
    @Published private(set) var poems = [Poem]()
    @Published private(set) var authorPoems = [Poem]()
    @Published private(set) var randomPoems = [Poem]()
    @Published var favoritePoems = [Poem]()
    
    
    @Published var searchTerm: String = ""
    
    //State variables
    @Published private(set) var state = State.idle
    @Published private(set) var searchState = SearchTitleState.idle
    
    
    
    //SearchView Handling - fetchs data for title search.
    
    func loadPoem(searchTerm: String, filter: DataManager.SearchFilter) {
        poems = []
        
        if searchTerm == "" {
            searchState = .idle
            return
        } else {
            searchState = .loading
            
            dataManager.loadData(filter: DataManager.SearchFilter.title, searchTerm: searchTerm) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .failure(let error):
                        self.searchState = .failed(error)
                        print(error.localizedDescription)
                    case .success(let searchedPoems):
                        self.searchState = .loaded
                        self.poems = searchedPoems
                    }
                }
            }
            
        }
    }
    
    //AuthorView Handling - loads authors poems in AuthorView
    func loadAuthorPoem(searchTerm: String) {
        authorPoems = []
        state = .loading
        
        dataManager.loadData(filter: DataManager.SearchFilter.author, searchTerm: searchTerm) { result in
            DispatchQueue.main.async {
                switch result {
                    
                case .failure(let error):
                    self.state = .failed(error)
                    print(error.localizedDescription)
                    
                case .success(let searchedPoems):
                    self.state = .loaded
                    
                    self.authorPoems = searchedPoems
                }
            }
        }
    }
    
    //HomeView Handling - fetchs random poem for Home Screen.
    func loadRandomPoems(searchTerm: String) {
        randomPoems = []
        state = .loading
        
        dataManager.loadData(filter: DataManager.SearchFilter.author, searchTerm: searchTerm) { result in
            DispatchQueue.main.async {
                switch result {
                    
                case .failure(let error):
                    self.state = .failed(error)
                    print(error.localizedDescription)
                    
                case .success(let searchedPoems):
                    self.state = .loaded
                    self.randomPoems = searchedPoems
                }
            }
        }
    }
    
    
    
    //FAVORITES HANDLING
    
    func contains(_ poem: Poem) -> Bool {
        favoritePoems.contains { $0.title == poem.title }
    }
    
    func addToFavorites(_ poem: Poem) {
        if contains(poem) {
            return
        } else {
            favoritePoems.append(poem)
        }
    }
    
    func removePoemFromFavorites(_ poem: Poem) {
        favoritePoems.removeAll(where: { $0.title == poem.title })
    }
    
    // QUOTES HANDLING
    
    func addQuote(_ quote: Quote) {
        if quotes.contains(where: { $0.quote == quote.quote }) {
            return
        } else {
            quotes.append(quote)
            print(quotes)
        }
    }
    
}



