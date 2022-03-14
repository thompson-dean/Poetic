//
//  Bundle-Decodable.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/09.
//

import Foundation

extension Bundle {
    func decode<T: Codable>(_ file: String) -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("no url")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("no data")
        }
        
        let decoder = JSONDecoder()
        
        guard let loaded = try? decoder.decode(T.self, from: data) else {
            fatalError("no decoding")
        }
        
        return loaded
        
    }

}
