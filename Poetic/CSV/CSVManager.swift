//
//  CSVManager.swift
//  Poetic
//
//  Created by Dean Thompson on 2023/07/22.
//

import Foundation
import CodableCSV

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
        var lines = poem.components(separatedBy: "\r\n").map { $0.trimmingCharacters(in: .whitespaces) }
        // Remove first and last empty lines if exist
        if let first = lines.first, first.isEmpty || first == "\r" {
            lines.removeFirst()
        }
        if let last = lines.last, last.isEmpty || last == "\r" {
            lines.removeLast()
        }
        return lines.joined(separator: "\n")
    }
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case poem = "Poem"
        case poet = "Poet"
        case tags = "Tags"
    }
}

protocol CSVParsing {
    func parseCSV(fileName: String, fileType: String) -> [CSVPoem]
}

class CSVManager: CSVParsing {
    
    static let shared = CSVManager()
    
    private init() {}
    
    func parseCSV(fileName: String, fileType: String) -> [CSVPoem] {
        guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: fileType) else {
            print("File not found")
            return []
        }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = CSVDecoder {
                $0.headerStrategy = .firstLine
                $0.delimiters.row = "\r\n"
                $0.nilStrategy = .empty
            }
            let result = try decoder.decode([CSVPoem].self, from: data)
            return result
        } catch {
            print("Failed to parse CSV: \(error)")
            return []
        }
    }
}
