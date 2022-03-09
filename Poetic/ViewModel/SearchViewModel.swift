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
    
   
    
    @Published private(set) var state = State.idle
    
    @Published var favoritePoems = [Poem]()
    
    @Published var searchTerm: String = ""
    @Published private(set) var poems: [Poem] = []

    let dataManager = DataManager()
    
    
    func loadPoem(searchTerm: String, filter: DataManager.SearchFilter) {
        
        poems.removeAll()
        state = .loading
        dataManager.loadData(filter: filter, searchTerm: searchTerm) { result in
            switch result {
            case .failure(let error):
                self.state = .failed(error)
                print(error.localizedDescription)
            case .success(let searchedPoems):
                self.state = .loaded
                DispatchQueue.main.async {
                    self.poems = searchedPoems
                }
                
            }
            
            
            
        }
    }
    
    func filterAuthors(searchTerm: String, authors: Authors) {
        
    }

    
    func addpoemToFavorites(poem: Poem) {
        favoritePoems.append(poem)
    }
    
    
}
