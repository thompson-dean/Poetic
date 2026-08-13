//
//  PoemExcerpt.swift
//  Poetic
//
//  Created by Dean Thompson on 2026/08/11.
//

import Foundation

/// Shared excerpt logic: the first meaningful lines of a poem, used by
/// PoemCard previews and widget payloads.
enum PoemExcerpt {
    static func lines(from poemLines: [String], limit: Int) -> [String] {
        var excerpt = [String]()
        for line in poemLines {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty && trimmed.count >= 4 {
                excerpt.append(trimmed)
                if excerpt.count == limit {
                    break
                }
            }
        }
        return excerpt
    }
}
