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
    @Environment(\.appTheme) private var theme

    var body: some View {
        ForEach(0..<5) { _ in
            HStack {
                ZStack {
                    switch type {
                    case .failed:
                        PoemCard(poem: Poem.stub)
                            .redacted(reason: .placeholder)
                        VStack(alignment: .center, spacing: 8) {
                            Image(systemName: "exclamationmark.triangle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 44, height: 44)
                            Text("Couldn't load poems. Pull to refresh.")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(theme.accent(for: colorScheme))
                    case .idle:
                        PoemCard(poem: Poem.stub)
                            .redacted(reason: .placeholder)
                            .foregroundColor(theme.accent(for: colorScheme))
                    }
                }
            }
        }
        .padding(.leading, 8)
    }
}
