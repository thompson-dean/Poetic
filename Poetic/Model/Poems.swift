//
//  Poems.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import Foundation


struct Poem: Codable, Identifiable {
    let id = UUID()
    let title: String
    let author: String
    let lines: [String]
    let linecount: String
}
