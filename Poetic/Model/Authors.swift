//
//  Authors.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/13.
//

import SwiftUI

struct Authors: Codable, Identifiable {
    let id = UUID()
    var authors: [String]
}
