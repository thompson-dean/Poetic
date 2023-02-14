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
            
            Text(poem.author)
                .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 20)
                .padding(.top, 8)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 4) {
                
                if poem.lines[0].trimmingCharacters(in: .whitespacesAndNewlines) == "" || poem.lines[0].count < 8 {
                    if poem.lines[1].trimmingCharacters(in: .whitespacesAndNewlines) == "" || poem.lines[1].count < 8 {
                        Text(poem.lines[2].trimmingCharacters(in: .whitespaces))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(2)
                            .foregroundColor(.primary)
                            .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .medium), lineHeight: 22)
                    } else {
                        Text(poem.lines[1].trimmingCharacters(in: .whitespaces))
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(2)
                            .foregroundColor(.primary)
                            .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .medium), lineHeight: 22)
                    }
                } else {
                    Text(poem.lines[0].trimmingCharacters(in: .whitespaces))
                        .fixedSize(horizontal: false, vertical: true)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                        .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .medium), lineHeight: 22)
                }
            }
            
            Text("...")
            
            Spacer()
            
            Text(poem.title)
                .foregroundColor(colorScheme == .light ? .lightThemeColor : .darkThemeColor)
                .lineLimit(2)
                .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .medium), lineHeight: 24)
                .padding(.bottom, 8)
        }
        .padding(.horizontal, 8)
        .frame(width: 254, alignment: .leading)
        .frame(maxHeight: 176)
        .background(colorScheme == .light ? .white : .black)
        .cornerRadius(8)
    }
}

struct PoemCard_Previews: PreviewProvider {
    static var previews: some View {
        PoemCard(poem: Poem(
            title: "Sonnet 1: From fairest creatures we desire increase",
            author: "William Shakespeare",
            lines: [
                "he",
                "Th",
                "But as the riper should by time decease, fadafgafsgafafgafgafgadfg",
                "His tender heir might bear his memory: afafdgafgafgafgadfgadfg",
                "But thou contracted to thine own bright eyes,",
                "Feed'st thy light's flame with self-substantial fuel,",
                "Making a famine where abundance lies,",
                "Thy self thy foe, to thy sweet self too cruel:",
                "Thou that art now the world's fresh ornament,",
                "And only herald to the gaudy spring,",
                "Within thine own bud buriest thy content,",
                "And tender churl mak'st waste in niggarding:",
                " Pity the world, or else this glutton be,",
                " To eat the world's due, by the grave and thee."
            ],
            linecount: "14"))
        .previewLayout(.sizeThatFits)
    }
}
