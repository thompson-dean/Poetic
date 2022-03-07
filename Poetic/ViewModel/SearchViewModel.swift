//
//  SearchViewModel.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import Foundation

class SearchViewModel: ObservableObject {
    @Published var searchTerm: String = ""
    @Published public private(set) var poems: [Poem] = []
    
    let dataManager = DataManager()
    
    
    func loadPoem(searchterm: String, filter: DataManager.SearchFilter) {
        
        poems.removeAll()
        dataManager.loadData(filter: filter, searchTerm: searchTerm) { searchedPoems in
            DispatchQueue.main.async {
                
                self.poems = searchedPoems
            }
            
            
        }
    }
    
    
}
