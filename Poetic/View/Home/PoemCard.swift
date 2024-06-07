//
//  PoemCard.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/09/04.
//

import SwiftUI

struct PoemCard: View {
    @Environment(\.colorScheme) var colorScheme
    let poem: Poem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            authorText
            poemLines
            Text("...")
            Spacer()
            titleText
        }
        .padding(.horizontal, 8)
        .frame(width: 254, alignment: .leading)
        .frame(maxHeight: 176)
        .background(cardBackgroundColor)
        .cornerRadius(8)
    }
    
    private var authorText: some View {
        Text(poem.author)
            .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 20)
            .padding(.top, 8)
            .foregroundColor(.primary)
    }
    
    private var titleText: some View {
        Text(poem.title)
            .foregroundColor(colorScheme == .light ? .lightThemeColor : .darkThemeColor)
            .lineLimit(2)
            .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .medium), lineHeight: 24)
            .padding(.bottom, 8)
    }
    
    private var poemLines: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(filteredLines(poem.lines), id: \.self) { line in
                Text(line)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                    .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .medium), lineHeight: 22)
            }
        }
    }
    
    private var cardBackgroundColor: Color {
        colorScheme == .light ? .white : .black
    }
    
    private func filteredLines(_ lines: [String]) -> [String] {
        var result: [String] = []
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedLine.isEmpty && trimmedLine.count >= 4 {
                result.append(trimmedLine)
                if result.count == 3 {
                    break
                }
            }
        }
        return result
    }
}

struct PoemCard_Previews: PreviewProvider {
    static var previews: some View {
        PoemCard(poem: Poem.stub)
            .previewLayout(.sizeThatFits)
    }
}
