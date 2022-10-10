//
//  PKHUDView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/10/10.
//

import Foundation

import SwiftUI
import PKHUD

struct PKHUDView: UIViewRepresentable {
    @Binding var isPresented: Bool
    var HUDContent: HUDContentType
    var delay: Double
    func makeUIView(context: UIViewRepresentableContext<PKHUDView>) -> UIView {
        return UIView()
    }
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PKHUDView>) {
        if isPresented {
            HUD.flash(HUDContent, delay: delay) { finished in
                isPresented = false
            }
        }
    }
}

struct PKHUDViewModifier<Parent: View>: View {
    @Binding var isPresented: Bool
    var HUDContent: HUDContentType
    var delay: Double
    var parent: Parent
    var body: some View {
        ZStack {
            parent
            if isPresented {
                PKHUDView(isPresented: $isPresented, HUDContent: HUDContent, delay: delay)
            }
        }
    }
}
