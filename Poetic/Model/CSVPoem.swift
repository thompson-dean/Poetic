//
//  CSVPoem.swift
//  Poetic
//
//  Created by Dean Thompson on 2023/07/23.
//

import Foundation

struct CSVPoem: Codable, Hashable {
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
            return cleanUpString(poem)
        }
    
    private func cleanUpString(_ str: String) -> String {
            var cleanedString = str.trimmingCharacters(in: .whitespacesAndNewlines)

            // Count number of occurrences of "\r\r\n"
            let count = cleanedString.components(separatedBy: "\r\r\n").count - 1

            if count <= 2 {
                // Replace ". " with ".\n" only if there are no more than two "\r\r\n" occurrences
                cleanedString = cleanedString.replacingOccurrences(of: ". ", with: ".\n")
            }

            return cleanedString
        }
    
    enum CodingKeys: String, CodingKey {
        case title = "Title"
        case poem = "Poem"
        case poet = "Poet"
        case tags = "Tags"
    }
}

extension CSVPoem: Identifiable {
    var id: UUID {
        UUID()
    }
}
//
//extension CSVPoem: RawRepresentable {
//    public init?(rawValue: String) {
//        guard let data = rawValue.data(using: .utf8),
//            let result = try? JSONDecoder().decode(CSVPoem.self, from: data)
//        else {
//            return nil
//        }
//        self = result
//    }
//
//    public var rawValue: String {
//        guard let data = try? JSONEncoder().encode(self),
//            let result = String(data: data, encoding: .utf8)
//        else {
//            return "[]"
//        }
//        return result
//    }
//}
