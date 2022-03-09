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
    
    func loadData(filter: SearchFilter, searchTerm: String, completion: @escaping(Result<[Poem], ErrorType>) -> Void) {
        guard !searchTerm.isEmpty else { return }
        
        let api = "https://poetrydb.org/\(filter)/"
        guard let url = URL(string: "\(api)\(searchTerm)") else { return }
        print(url)
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let _ = error {
                completion(.failure(.invalidSearch))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let poems = try decoder.decode([Poem].self, from: data)
                completion(.success(poems))
                
            } catch {
                completion(.failure(.invalidData))
            }
        }
        dataTask.resume()
    }
    
    
    
    
}



