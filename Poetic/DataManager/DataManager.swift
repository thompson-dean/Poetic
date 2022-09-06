//
//  DataManager.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import SwiftUI

class DataManager {
    
    var placeholderData: Poem = Poem(
        title: "Sonnet 1: From fairest creatures we desire increase",
        author: "William Shakespeare",
        lines: [
            "From fairest creatures we desire increase,",
            "That thereby beauty's rose might never die,",
            "But as the riper should by time decease, ",
            "His tender heir might bear his memory",
            "But thou contracted to thine own bright eyes,",
            "Feed'st thy light's flame with self-substantial fuel,",
            "Making a famine where abundance lies,",
            "Thy self thy foe, to thy sweet self too cruel:",
            "Thou that art now the world's fresh ornament,",
            "And only herald to the gaudy spring,",
            "Within thine own bud buriest thy content,",
            "And tender churl mak'st waste in niggarding:",
            " Pity the world, or else this glutton be,",
            " To eat the world's due, by the grave and thee."
        ],
        linecount: "14")
    
    var dataTask: URLSessionDataTask?
    
    enum SearchFilter: String {
        case author = "author"
        case title = "title"
        case random = "random"
    }
    
    
    func loadData(filter: SearchFilter, searchTerm: String, completion: @escaping(Result<[Poem], ErrorType>) -> Void) {
        
        guard !searchTerm.isEmpty else { return }
        
        let api = "https://poetrydb.org/\(filter)/"
        guard let url = URL(string: "\(api)\(searchTerm)") else { return }
        
        dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            
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
                self.dataTask?.cancel()
            } catch {
                completion(.failure(.invalidData))
            }
        }
        dataTask?.resume()
    }
}



