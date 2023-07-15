//
//  Mockable.swift
//  PoeticTests
//
//  Created by Dean Thompson on 2023/07/15.
//

import Foundation

protocol Mockable: AnyObject {
    var bundle: Bundle { get }
    func loadJSON<T: Decodable>(filename: String, type: T.Type) -> [T]
}

extension Mockable {
    var bundle: Bundle {
        return Bundle(for: type(of: self))
    }
    
    func loadJSON<T: Decodable>(filename: String, type: T.Type) -> [T] {
        guard let url = bundle.url(forResource: filename, withExtension: "json") else {
            fatalError("Failed to load JSON File")
        }
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("no data")
        }
        
        let decoder = JSONDecoder()
        
        guard let loaded = try? decoder.decode([T].self, from: data) else {
            fatalError("no decoding")
        }
        return loaded
    }
}
