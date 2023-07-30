//
//  PoemCard.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/09/04.
//

import SwiftUI

struct PoemCard: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let poem: CSVPoem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            
            Text(poem.cleanedPoet)
                .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 20)
                .padding(.top, 8)
                .foregroundColor(.primary)
            
            Text(poem.cleanedPoem)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(4)
                .foregroundColor(.primary)
                .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .medium), lineHeight: 22)
            
            Spacer()
            
            Text(poem.cleanedTitle)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(colorScheme == .light ? .lightThemeColor : .darkThemeColor)
                .lineLimit(3)
                .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .medium), lineHeight: 24)
                .padding(.bottom, 8)
        }
        .padding(.horizontal, 8)
        .frame(width: 254, alignment: .leading)
//        .frame(maxHeight: 176)
        .background(colorScheme == .light ? .white : .black)
        .cornerRadius(8)
    }
}

struct PoemCard_Previews: PreviewProvider {
    static var previews: some View {
        PoemCard(poem: CSVPoem(title: "", poem: "", poet: "", tags: ""))
            .previewLayout(.sizeThatFits)
    }
}
