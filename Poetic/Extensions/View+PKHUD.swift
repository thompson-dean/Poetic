//
//  View+PKHUD.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/10/10.
//

import SwiftUI
import PKHUD

extension View {
    public func PKHUD(isPresented: Binding<Bool>, HUDContent: HUDContentType, delay: Double) -> some View {
        PKHUDViewModifier(isPresented: isPresented, HUDContent: HUDContent, delay: delay, parent: self)
    }
}
