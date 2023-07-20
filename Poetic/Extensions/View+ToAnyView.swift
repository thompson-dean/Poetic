//
//  View+ToAnyView.swift
//  Poetic
//
//  Created by Dean Thompson on 2023/07/20.
//

import SwiftUI

extension View {
    func toAnyView() -> AnyView {
        AnyView(self)
    }
}
