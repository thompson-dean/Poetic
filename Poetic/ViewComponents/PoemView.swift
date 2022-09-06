//
//  PoemView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/06/08.
//

import SwiftUI

struct PoemView: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let links = Links()
    
    @ObservedObject var viewModel: PoemViewModel
    @ObservedObject var pcViewModel: PersistenceController
    
    let author: String
    let title: String
    let index: Int
    let poemLines: [String]
    var body: some View {
        
        if pcViewModel.quotes.contains(where: { $0.quote == poemLines[index] }) {
            Text(poemLines[index].trimmingCharacters(in: .whitespacesAndNewlines))
                .font(.system(.callout, design: .serif))
                .foregroundColor(Color.black)
                .background(Color.yellow)
        
                .contextMenu {
                    Button {
                        links.shareQuote(quote: poemLines[index].trimmingCharacters(in: .whitespacesAndNewlines), title: title, author: author)
                    } label: {
                        Label("Share this quote", systemImage: "square.and.arrow.up")
                    }
                    
                    Button {
                        // return
                        
                    } label: {
                        Label("Cancel", systemImage: "delete.left")
                            
                    }
                }
        } else {
            Text(poemLines[index].trimmingCharacters(in: .whitespacesAndNewlines))
                .font(.system(.body, design: .serif))
                .contextMenu {
                    Button {
                        if !pcViewModel.quotes.contains(where: { $0.quote == poemLines[index].trimmingCharacters(in: .whitespacesAndNewlines)}) {
                            pcViewModel.addQuote(id: UUID(), title: title, author: author, quote: poemLines[index], lines: poemLines, linecount: "")
                            viewModel.simpleHapticSuccess()
                        }
                    } label: {
                        Label("Highlight and Save", systemImage: "quote.bubble.fill")
                    }
                    Button {
                        links.shareQuote(quote: poemLines[index].trimmingCharacters(in: .whitespacesAndNewlines), title: title, author: author)
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
