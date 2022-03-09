//
//  AuthorViewModel.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/09.
//

import Foundation

class AuthorViewModel: ObservableObject {
    var dataManager = DataManager()
    
    enum State {
        case idle
        case loading
        case failed(Error)
        case loaded
    }
    @Published private(set) var state = State.idle
    @Published private(set) var authorPoems = [Poem]()
    
    func loadAuthorPoem(searchTerm: String) {
        
        authorPoems.removeAll()
        state = .loading
        dataManager.loadData(filter: DataManager.SearchFilter.author, searchTerm: searchTerm) { result in
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
