//
//  DetailView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import SwiftUI

struct DetailView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var viewModel: SearchViewModel
    @ObservedObject var pcViewModel: PersistenceController
    
    let title: String
    let author: String
    let lines: [String]
    let linecount: String
   
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                
                VStack {
                    
                    Text(title)
                        .font(.system(.title2, design: .serif))
                        .fontWeight(.semibold)
                        .padding(.vertical, 9)
                        .padding(.horizontal)
                
                    Text(author)
                        .font(.system(.headline, design: .serif))
                        .padding(.bottom, 10)
                        .padding(.horizontal)
                    
                    Divider()
                        .frame(width: geo.size.width / 2)
                        .padding(10)
                    
                    VStack(alignment: .leading) {
                        ForEach(0..<lines.count, id: \.self) { index in
                            HStack {
                                if lines.count < 9 {
                                    Text("\(index + 1)")
                                        .font(.system(.caption2, design: .serif))
                                        .frame(width: 20, height: 10)
                                        .padding(.trailing, 5)
                                        
                                } else {
                                    Text((index + 1) % 5 == 0 ? "\(index + 1)" : "")
                                        .font(.system(.caption2, design: .serif))
                                        .frame(width: 30, height: 10)
                                        .padding(.trailing, 5)
                                        
                                }
                                
                                PoemView(viewModel: viewModel, pcViewModel: pcViewModel, author: author, title: title, index: index, poemLines: lines)
                                
                            }
                            .padding(.vertical, 1)
                        }
                    }
                    .padding(5)
                }
                .frame(width: geo.size.width)
            }
            .background(
                Image(colorScheme == .light ? "background" : "background-dark")
                    .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                    .ignoresSafeArea()
            )
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if let entity = pcViewModel.favoritedPoems.first(where: { $0.title == title}) {
                        pcViewModel.deleteFavoritedPoemFromTappingStar(entity: entity)
                    } else {
                        pcViewModel.addFavoritePoem(id: UUID(), title: title, author: author, lines: lines, linecount: linecount)
                    }
                    
                } label: {
                    if pcViewModel.favoritedPoems.contains(where: { $0.title == title })  {
                        Image(systemName: "star.fill")
                    } else {
                        Image(systemName: "star")
                    }
                }
            
            }
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {}
            }
        }
    }
}

struct PoemView: View {
    
    @ObservedObject var viewModel: SearchViewModel
    @ObservedObject var pcViewModel: PersistenceController
    
    let author: String
    let title: String
    let index: Int
    let poemLines: [String]
    var body: some View {
        Text(poemLines[index].trimmingCharacters(in: .whitespacesAndNewlines))
            .font(.system(.subheadline, design: .serif))
            .contextMenu {
                Button {
                    if !pcViewModel.quotes.contains(where: { $0.quote == poemLines[index]}) {
                        pcViewModel.addQuote(id: UUID(), title: title, author: author, quote: poemLines[index])
                        viewModel.simpleHapticSuccess()
                    }
                } label: {
                    Label("Add to Fav Quotes", systemImage: "quote.bubble.fill")
                }
                Button {
                    
                } label: {
                    Label("Cancel", systemImage: "delete.left")
                        
                }
            }
        
    }
}
