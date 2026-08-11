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
    @EnvironmentObject var store: PoemStore

    init(viewModel: PoemViewModel) {
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().backgroundColor = .clear
        UITableView.appearance().showsVerticalScrollIndicator = false
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            VStack {
                if store.favorites.isEmpty {
                    ContentUnavailableView(
                        "No favourites yet!",
                        systemImage: "star",
                        description: Text("Tap the star to save your favourite poems.")
                    )
                } else {
                    List {
                        ForEach(store.favorites) { poem in
                            ZStack {
                                NavigationLink {
                                    DetailView(poem: poem.asPoem())
                                } label: {
                                    EmptyView().opacity(0.0)
                                }
                                TitleAuthorFavoriteCell(poem: poem)
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(.init(top: 0,
                                                 leading: 0,
                                                 bottom: 0,
                                                 trailing: 0))
                        }
                        .onDelete { indexSet in
                            store.deleteFavorites(at: indexSet)
                        }
                    }
                    .scrollIndicators(ScrollIndicatorVisibility.hidden)
                    .cornerRadius(8)
                    .padding(8)
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(
                Image(colorScheme == .light ? "background" : "background-dark")
                    .resizable(capInsets: EdgeInsets(), resizingMode: .tile)
                    .ignoresSafeArea(.all)
            )
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.inline)
            .foregroundColor(.primary)
            .toolbar {
                ToolbarItem {
                    EditButton()
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        store.favoriteSort = store.favoriteSort == .title ? .author : .title
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
            }
        }
    }
}
