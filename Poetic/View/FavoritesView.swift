//
//  FavoritesView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import SwiftUI

struct FavoritesView: View {
    
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        NavigationView {
            
            ZStack {
                Image("background")
                    .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                    .ignoresSafeArea()
                
                GeometryReader { geo in
                    List {
                        ForEach(viewModel.favoritePoems) { poem in
                            NavigationLink {
                                DetailView(viewModel: viewModel, title: poem.title, author: poem.author, poemLines: poem.lines, linecount: poem.linecount)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(poem.title)
                                        .font(.system(.headline, design: .serif))
                                        .multilineTextAlignment(.leading)
                                    Text(poem.author)
                                        .font(.system(.subheadline, design: .serif))
                                    
                                }
                                
                            }
                            
                        }
                        .onDelete(perform: removeRows)
                    }
                }
                .navigationTitle("Favorites")
                .navigationBarTitleDisplayMode(.inline)
                .foregroundColor(.black)
                
            }
            .toolbar {
                EditButton()
            }
        }
    }
    
    func removeRows(at offsets: IndexSet) {
        viewModel.favoritePoems.remove(atOffsets: offsets)
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView(viewModel: SearchViewModel())
    }
}
