//
//  CSVPoem.swift
//  Poetic
//
//  Created by Dean Thompson on 2023/07/23.
//

import Foundation

struct CSVPoem: Codable {
    let title: String
    let poem: String
    let poet: String
    let tags: String?
    
    var parsedTags: [String] {
        return tags?.components(separatedBy: ",") ?? []
    }
    
    var cleanedTitle: String {
        return title.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var cleanedPoet: String {
        return poet.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var cleanedPoem: String {
            var lines = poem.components(separatedBy: "\r\n").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

            while let first = lines.first, first.isEmpty {
                lines.removeFirst()
            }
            while let last = lines.last, last.isEmpty {
                lines.removeLast()
            }

            return lines.joined(separator: "\r\n")
        }
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case poem = "Poem"
        case poet = "Poet"
        case tags = "Tags"
    }
}
