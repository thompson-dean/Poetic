//
//  QuoteCellView.swift
//  Poetic
//
//  Created by Dean Thompson on 2023/02/18.
//

import SwiftUI

struct QuoteCellView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var pcViewModel: PersistenceController
    
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    
                    Text(("""
                                    "\(pcViewModel.quotes[index].quote ?? "Unknown Line")"
                                """).trimmingCharacters(in: .whitespacesAndNewlines))
                    .fixedSize(horizontal: false, vertical: true)
                    .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 20)
                    
                    Text(pcViewModel.quotes[index].title ?? "Unknown Title")
                        .fixedSize(horizontal: false, vertical: true)
                        .fontWithLineHeight(font: .systemFont(ofSize: 14, weight: .regular), lineHeight: 16)
                        .foregroundColor(colorScheme == .light ? .lightThemeColor : .darkThemeColor)
                    
                    Text(pcViewModel.quotes[index].author ?? "Unknown Title")
                        .fixedSize(horizontal: false, vertical: true)
                        .fontWithLineHeight(font: .systemFont(ofSize: 14, weight: .semibold), lineHeight: 16)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
        }
        .background(colorScheme == .light ? .white : .black)
        .cornerRadius(8)
        .padding(.vertical, 4)
    }
}


struct QuoteCellView_Previews: PreviewProvider {
    static var previews: some View {
        QuoteCellView(pcViewModel: PersistenceController(), index: 1)
    }
}
