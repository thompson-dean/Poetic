//
//  Quote.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/13.
//

import Foundation

struct Quote: Identifiable {
    var id = UUID()
    var  title: String
    var author: String
    var quote: String
}


