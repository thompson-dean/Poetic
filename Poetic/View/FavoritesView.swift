//
//  FavoritesView.swift
//  Poetic
//
//  Created by Dean Thompson on 2022/03/07.
//

import SwiftUI

struct FavoritesView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var viewModel: SearchViewModel
    @ObservedObject var pcViewModel: PersistenceController
    
    var body: some View {
        NavigationView {
            
            ZStack {
                GeometryReader { geo in
                    List {
                        ForEach(pcViewModel.favoritedPoems) { poem in
                            NavigationLink {
                                DetailView(viewModel: viewModel, pcViewModel: pcViewModel, title: poem.title ?? "", author: poem.author ?? "", lines: poem.lines ?? [""], linecount: poem.linecount ?? "")
                            } label: {
                                VStack(alignment: .leading, spacing: 7) {
                                    Text(poem.title ?? "")
                                        .font(.system(.headline, design: .serif))
                                        .multilineTextAlignment(.leading)
                                    Text(poem.author ?? "")
                                        .font(.system(.subheadline, design: .serif))
                                    
                                    
                                }
                                .padding(.bottom, 3)
                                
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
    
    func removeRows(at offsets: IndexSet) {
        viewModel.favoritePoems.remove(atOffsets: offsets)
    }
}

struct FavoritesView_Previews: PreviewProvider {
    
    static var previews: some View {
        FavoritesView(viewModel: SearchViewModel(), pcViewModel: PersistenceController())
    }
}
