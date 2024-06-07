//
//  FailedPoemCard.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/09/07.
//

import SwiftUI

struct RedactedPoemCardView: View {
    enum RedactedType {
        case failed, idle
    }
    
    let type: RedactedType
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ForEach(0..<5) { _ in
            HStack {
                ZStack {
                    switch type {
                    case .failed:
                        PoemCard(poem: Poem.stub)
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
                    case .idle:
                        PoemCard(poem: Poem.stub)
                            .redacted(reason: .placeholder)
                            .foregroundColor(colorScheme == .light ? .lightThemeColor : .darkThemeColor)
                    }
                }
            }
        }
        .padding(.leading, 8)
    }
}

struct RedactedPoemCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            RedactedPoemCardView(type: .failed)
            RedactedPoemCardView(type: .idle)
        }
        .previewLayout(.sizeThatFits)
    }
}
