//
//  PoetBio.swift
//  Poetic
//
//  Created by Dean Thompson on 2026/08/13.
//

import Foundation

struct PoetBio: Codable, Hashable, Identifiable {
    /// Exact catalog author key — must match `Poem.author` so navigation
    /// and poem lookups work.
    let author: String
    /// Set only when the catalog key reads badly as a display name
    /// (e.g. "Robinson" → "Mary Robinson").
    let displayName: String?
    let years: String
    let blurb: String

    var id: String { author }

    var name: String { displayName ?? author }
}
