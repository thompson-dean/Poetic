//
//  LineBreak.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/09.
//

import SwiftUI
struct LineBreak: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))

        return path
    }
}
