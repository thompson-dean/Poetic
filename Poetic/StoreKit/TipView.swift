//
//  TipView.swift
//  Poetic
//
//  Created by Dean Thompson on 2023/07/20.
//

import SwiftUI
import StoreKit

struct TipView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var storeKitManager: StoreKitManager
    @State private var showThankYou: Bool = false
    
    var body: some View {
        mainTipView
    }
    
    var mainTipView: some View {
        VStack(alignment: .center, spacing: 8) {
            
            ForEach(storeKitManager.items) { item in
                Button {
                    Task {
                        await storeKitManager.purchase(item)
                    }
                } label: {
                    VStack() {
                        Text(item.displayName)
                            .bold()
                        Text(item.description)
                        Text(item.displayPrice)
                    }
                    .background(.red)
                    .cornerRadius(8)
                }
            }
        }
        .onChange(of: storeKitManager.paymentState) { state in
            if state == .successful {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.showThankYou = true
                    storeKitManager.reset()
                }
            }
        }
        .alert(isPresented: $storeKitManager.hasError, error: storeKitManager.error) { }
        .sheet(isPresented: $showThankYou) {
            thankYouView
        }
    }
    
    var thankYouView: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("THANK YOU BRUH")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
    }
}

