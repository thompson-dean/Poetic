//
//  Authors.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/13.
//

import SwiftUI

struct Authors: Codable {
    var authors: [String]
}

extension Authors: Identifiable {
    var id: UUID {
        UUID()
    }
}
