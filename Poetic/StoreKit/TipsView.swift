//
//  TipsView.swift
//  Poetic
//
//  Created by Dean Thompson on 2023/07/20.
//

import SwiftUI
import StoreKit

struct TipsView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var storeKitManager: StoreKitManager
    @Binding var isShowingTipsView: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Spacer()
                Button {
                    isShowingTipsView.toggle()
                } label: {
                    Image(systemName: "xmark")
                        .symbolVariant(.circle.fill)
                        .font(.system(.largeTitle, design: .rounded).bold())
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.gray, .gray.opacity(0.2))
                }
            }
            
            Text("Enjoying the app so far?")
                .font(.system(.title2).bold())
                .multilineTextAlignment(.center)
            
            Text("If Poetic enriches your days or sparks your imagination, consider leaving a tip. Every contribution, large or small, helps enhance the Poetic App. Thank you for your generosity!")
               
                .multilineTextAlignment(.center)
                .padding(.bottom, 16)
            
            ForEach(storeKitManager.items) { item in
                TipsItemView(item: item) {
                    Task {
                        await storeKitManager.purchase(item)
                    }
                }
            }
        }
        .padding(16)
        .background(colorScheme == .light ? .white.opacity(0.9) : Color(0x181716) , in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .padding(8)
        .overlay(alignment: .top) {
            Image("poeticPic")
                .resizable()
                .scaledToFit()
                .cornerRadius(8)
                .frame(width: 50, height: 50)
                .padding(6)
                .offset(y: -25)
        }
    }
}

struct TipsItemView: View {
    @Environment(\.colorScheme) var colorScheme
    let item: Product
    let purchaseButtonTapped: () -> Void
    var body: some View {
        HStack {
            VStack(alignment: .leading,
                   spacing: 3) {
                Text(item.displayName)
                    .font(.system(.title3, design: .rounded).bold())
                Text(item.description)
                    .font(.system(.callout, design: .rounded).weight(.regular))
            }
            
            Spacer()
            
            Button(item.displayPrice) {
              purchaseButtonTapped()
            }
            .tint(colorScheme == .light ? Color.lightThemeColor : Color.darkThemeColor)
            .buttonStyle(.bordered)
            .font(.callout.bold())
        }
        .padding(16)
        .background(Color(UIColor.systemBackground),
                    in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

