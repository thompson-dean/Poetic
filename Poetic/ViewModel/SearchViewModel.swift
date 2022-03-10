//
//  SearchViewModel.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import Foundation

class SearchViewModel: ObservableObject {
    enum State {
        case idle
        case loading
        case failed(Error)
        case loaded
    }
    
    let dataManager = DataManager()
    
    @Published private(set) var poems = [Poem]()
    @Published private(set) var authorPoems = [Poem]()
    @Published var favoritePoems = [Poem]()
    
    @Published var searchTerm: String = ""
    
    @Published private(set) var state = State.idle
    
    
    //SearchView Handling
    
    func loadPoem(searchTerm: String, filter: DataManager.SearchFilter) {
        poems = []
        if searchTerm == "" {
            state = .idle
            return
        } else {
            state = .loading
            dataManager.loadData(filter: filter, searchTerm: searchTerm) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .failure(let error):
                        self.state = .failed(error)
                        print(error.localizedDescription)
                    case .success(let searchedPoems):
                        self.state = .loaded
                        self.poems = searchedPoems
                    }
                }
            }
            
        }
    }
    
    //AuthorView Handling
    
    func loadAuthorPoem(searchTerm: String) {
        print(searchTerm)
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
                    DispatchQueue.main.async {
                        self.authorPoems = searchedPoems
                    }
                    
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
    
}
