//
//  PoemView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/06/08.
//

import SwiftUI

struct PoemView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var pcViewModel: PersistenceController

    let author: String
    let title: String
    let index: Int
    let poemLines: [String]
    var body: some View {
        if pcViewModel.quotes.contains(where: { $0.quote == poemLines[index] }) {
            Text(poemLines[index].trimmingCharacters(in: .whitespacesAndNewlines))
                .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .medium), lineHeight: 18)
                .background(colorScheme == . light ? Color.lightHighlightThemeColor : Color.darkHighlightThemeColor)
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

                    Button { } label: {
                        Label("Cancel", systemImage: "delete.left")

                    }
                }
        } else {
            Text(poemLines[index].trimmingCharacters(in: .whitespacesAndNewlines))
                .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .medium), lineHeight: 18)
                .contextMenu {
                    Button {
                        if !pcViewModel.quotes
                            .contains(where: {
                                $0.quote == poemLines[index].trimmingCharacters(in: .whitespacesAndNewlines)
                            }) {
                            pcViewModel.addQuote(
                                id: UUID(),
                                title: title,
                                author: author,
                                quote: poemLines[index],
                                lines: poemLines
                            )
                            HapticFeedbackGenerator.shared.simpleHapticSuccess()
                        }
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
                    Button {

                    } label: {
                        Label("Cancel", systemImage: "delete.left")

                    }
                }
        }
    }
}
