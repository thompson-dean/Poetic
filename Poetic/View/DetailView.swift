//
//  DetailView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import SwiftUI

struct DetailView: View {
    
    @ObservedObject var viewModel: SearchViewModel
    
    let poem: Poem
   
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                
                VStack {
                    
                    Text(poem.title)
                        .font(.system(.title2, design: .serif))
                        .fontWeight(.semibold)
                        .padding(.vertical, 9)
                        .padding(.horizontal)
                
                    Text(poem.author)
                        .font(.system(.headline, design: .serif))
                        .padding(.bottom, 10)
                        .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        ForEach(0..<poem.lines.count) { index in
                            HStack {
                                if poem.lines.count < 9 {
                                    Text("\(index + 1)")
                                        .font(.system(.caption2, design: .serif))
                                        .frame(width: 22, height: 10)
                                        .padding(.trailing, 5)
                                        
                                } else {
                                    Text((index + 1) % 5 == 0 ? "\(index + 1)" : "")
                                        .font(.system(.caption2, design: .serif))
                                        .frame(width: 20, height: 10)
                                        .padding(.trailing, 5)
                                        
                                }
                                
                                PoemView(viewModel: viewModel, author: poem.author, title: poem.title, index: index, poemLines: poem.lines)
                                
                            }
                        }
                    }
                    .padding(5)
                }
                .frame(width: geo.size.width)
            }
            .background(
                Image("background")
                    .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                    .ignoresSafeArea()
            )
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    let newPoem = Poem(title: poem.title, author: poem.author, lines: poem.lines, linecount: poem.linecount)
                    if viewModel.contains(Poem(title: poem.title, author: poem.author, lines: poem.lines, linecount: poem.linecount)) {
                        
                        viewModel.removePoemFromFavorites(newPoem)
                    } else {
                        viewModel.addToFavorites(newPoem)
                    }
                    
                } label: {
                    if viewModel.contains(Poem(title: poem.title, author: poem.author, lines: poem.lines, linecount: poem.linecount)) {
                        Image(systemName: "star.fill")
                    } else {
                        Image(systemName: "star")
                    }
                }
            }
        }
    }
}

struct PoemView: View {
    
    @ObservedObject var viewModel: SearchViewModel
    
    let author: String
    let title: String
    let index: Int
    let poemLines: [String]
    var body: some View {
        Text(poemLines[index].trimmingCharacters(in: .whitespacesAndNewlines))
            .font(.system(.subheadline, design: .serif))
            .contextMenu {
                Button {
                    viewModel.addQuote(Quote(title: title, author: author, quote: poemLines[index]))
                    print("Tapped Favourites button")
                } label: {
                    Label("Add to Fav Quotes", systemImage: "quote.bubble.fill")
                }
                Button {
                    print("Selected Cancel Button")
                } label: {
                    Label("Cancel", systemImage: "delete.left")
                        .foregroundColor(.red)
                }
            }
        
    }
}
