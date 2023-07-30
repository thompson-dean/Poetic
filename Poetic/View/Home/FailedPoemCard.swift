//
//  FailedPoemCard.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/09/07.
//

import SwiftUI

struct FailedPoemCard: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var placeholderData: CSVPoem = CSVPoem(
        title: "Sonnet 1: From fairest creatures we desire increase",
        poem: """
            From fairest creatures we desire increase,
            That thereby beauty's rose might never die,
            But as the riper should by time decease,
            His tender heir might bear his memory
            But thou contracted to thine own bright eyes,
            Feed'st thy light's flame with self-substantial fuel,
            Making a famine where abundance lies,
            Thy self thy foe, to thy sweet self too cruel:
            Thou that art now the world's fresh ornament,
            And only herald to the gaudy spring,
            Within thine own bud buriest thy content,
            And tender churl mak'st waste in niggarding:
             Pity the world, or else this glutton be,
             To eat the world's due, by the grave and thee.
""", poet: "William Shakespeare",
        tags: nil)
    
    var body: some View {
        ZStack {
            PoemCard(poem: placeholderData)
                .redacted(reason: .placeholder)
            VStack(alignment: .center, spacing: 8) {
                Image(systemName: "wifi.exclamationmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                Text("Please connect to the internet.")
                    .fontWeight(.semibold)
            }
            .foregroundColor(colorScheme == .light ? .lightThemeColor : .darkThemeColor)
        }
    }
}

struct FailedPoemCard_Previews: PreviewProvider {
    static var previews: some View {
        FailedPoemCard()
            .previewLayout(.sizeThatFits)
    }
}
