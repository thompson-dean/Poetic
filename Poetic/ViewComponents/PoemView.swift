//
//  PoemView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/06/08.
//

import SwiftUI

struct PoemView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.appTheme) private var theme
    @EnvironmentObject var store: PoemStore

    let author: String
    let title: String
    let index: Int
    let poemLines: [String]
    /// True while this line is being read aloud.
    var isSpoken: Bool = false

    private var poem: Poem {
        Poem(title: title, author: author, lines: poemLines, linecount: String(poemLines.count))
    }

    var body: some View {
        line
            .padding(.horizontal, isSpoken ? 4 : 0)
            .background(
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(isSpoken ? theme.accent(for: colorScheme).opacity(0.18) : .clear)
            )
            .padding(.horizontal, isSpoken ? -4 : 0)
            .animation(.easeInOut(duration: 0.25), value: isSpoken)
    }

    @ViewBuilder
    private var line: some View {
        if store.hasQuote(poemLines[index], in: poem) {
            Text(poemLines[index].trimmingCharacters(in: .whitespacesAndNewlines))
                .fontWithLineHeight(font: theme.bodyFont(size: 16), lineHeight: 18)
                .background(theme.highlight(for: colorScheme))
                .contextMenu {
                    Button {
                        Links.shareQuote(
                            quote: poemLines[index].trimmingCharacters(in: .whitespacesAndNewlines),
                            title: title,
                            author: author
                        )
                    } label: {
                        Label("Share this quote", systemImage: "square.and.arrow.up")
                    }
                }
        } else {
            Text(poemLines[index].trimmingCharacters(in: .whitespacesAndNewlines))
                .fontWithLineHeight(font: theme.bodyFont(size: 16), lineHeight: 18)
                .contextMenu {
                    Button {
                        store.addQuote(poemLines[index], to: poem)
                        HapticFeedbackGenerator.shared.simpleHapticSuccess()
                    } label: {
                        Label("Highlight and Save", systemImage: "quote.bubble.fill")
                    }
                    Button {
                        Links.shareQuote(
                            quote: poemLines[index].trimmingCharacters(in: .whitespacesAndNewlines),
                            title: title,
                            author: author
                        )
                    } label: {
                        Label("Share this quote", systemImage: "square.and.arrow.up")
                    }
                }
        }
    }
}
