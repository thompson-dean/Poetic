//
//  FavoritesView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import SwiftUI

struct FavoritesView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var viewModel: PoemViewModel
    @ObservedObject var pcViewModel: PersistenceController
    
    var body: some View {
        NavigationView {
            
            ZStack {
                GeometryReader { geo in
                    List {
                        ForEach(pcViewModel.favoritedPoems) { poem in
                            NavigationLink {
                                let sentPoem = Poem(title: poem.title ?? "", author: poem.author ?? "", lines: poem.lines ?? [], linecount: poem.linecount ?? "")
                                NewDetailView(viewModel: viewModel, pcViewModel: pcViewModel, poem: sentPoem)
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    
                                    Text(poem.author ?? "")
                                        .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .bold), lineHeight: 24)
                                        .foregroundColor(.primary)
                                    
                                    Text(poem.title ?? "")
                                        .fontWithLineHeight(font: .systemFont(ofSize: 16, weight: .semibold), lineHeight: 24)
                                        .foregroundColor(colorScheme == .light ? Color(0x570861) : Color(0xDAAFFC))
                                }
                                
                            }
                            
                        }
                        .onDelete(perform: pcViewModel.deleteFavoritedPoem)
                    }
                }
                .background(
                    Image(colorScheme == .light ? "background" : "background-dark")
                        .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                        .ignoresSafeArea()
                    
                )
                .onAppear {
                    // Set the default to clear
                    UITableView.appearance().backgroundColor = .clear
                    pcViewModel.fetchFavoritedPoems()
                }
                .navigationTitle("Favorites")
                .navigationBarTitleDisplayMode(.inline)
                .foregroundColor(.primary)
                
            }
            
            .toolbar {
                ToolbarItem {
                    EditButton()
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        pcViewModel.poemsFilter.toggle()
                        pcViewModel.fetchFavoritedPoems()
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct FavoritesView_Previews: PreviewProvider {
    
    static var previews: some View {
        FavoritesView(viewModel: PoemViewModel(), pcViewModel: PersistenceController())
    }
}
