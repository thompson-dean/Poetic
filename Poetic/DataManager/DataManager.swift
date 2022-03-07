//
//  DataManager.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import SwiftUI

class DataManager {
    
    enum SearchFilter: String {
        case author = "author"
        case title = "title"
    }
    
    func loadData(filter: SearchFilter, searchTerm: String, completion: @escaping(([Poem]) -> Void)) {
        guard !searchTerm.isEmpty else { return }
        
        let api = "https://poetrydb.org/\(filter)/"
        guard let url = URL(string: "\(api)\(searchTerm)") else { return }
        print(url)
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print("jazz")
                completion([])
                return
            }
            
            let decoder = JSONDecoder()
            if let poems = try? decoder.decode([Poem].self, from: data) {
                completion(poems)
            } else {
                print("error")
            }
        }
            dataTask.resume()
    }
        
    
    
    
}



